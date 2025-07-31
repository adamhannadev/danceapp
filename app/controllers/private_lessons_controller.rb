class PrivateLessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_private_lesson, only: [:show, :edit, :update, :destroy, :cancel, :confirm]
  before_action :ensure_authorized, only: [:edit, :update, :destroy, :cancel, :confirm]

  def index
    @private_lessons = current_user.admin? ? 
      PrivateLesson.includes(:student, :instructor, :location) :
      current_user.instructor? ?
        current_user.private_lessons_as_instructor.includes(:student, :location) :
        current_user.private_lessons_as_student.includes(:instructor, :location)
    
    # Filter by status if specified
    @private_lessons = @private_lessons.where(status: params[:status]) if params[:status].present?
    
    # Filter by date range
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @private_lessons = @private_lessons.where(scheduled_at: start_date.beginning_of_day..end_date.end_of_day)
    end
    
    @private_lessons = @private_lessons.order(:scheduled_at).page(params[:page])
    
    # Statistics for the view
    @stats = {
      total: @private_lessons,
      upcoming: @private_lessons.where(status: 'scheduled', scheduled_at: Time.current..),
      completed: @private_lessons.where(status: 'completed'),
      cancelled: @private_lessons.where(status: 'cancelled')
    }
  end

  def show
    @previous_lesson = PrivateLesson.where(student_id: @private_lesson.student_id)
                                .where('scheduled_at < ?', @private_lesson.scheduled_at)
                                .order(scheduled_at: :desc)
                                .first
  end

  def new
    @private_lesson = PrivateLesson.new
    set_form_data
  end

  def available_slots
    # Step 1: User selects instructor and duration
    # Step 2: Show available dates for that instructor/duration
    # Step 3: Show available time slots for selected date
    
    @duration = params[:duration]&.to_i || 60
    @instructor_id = params[:instructor_id]&.to_i
    @student_id = params[:student_id]&.to_i
    @date = params[:date] ? Date.parse(params[:date]) : nil
    @location_id = params[:location_id]&.to_i
    
    set_form_data
    
    if @instructor_id && @duration
      @instructor = User.find(@instructor_id)
      @available_dates = get_available_dates(@instructor, @duration)
      
      if @date && @available_dates.include?(@date)
        @available_slots = calculate_available_slots(@instructor, @date, @duration)
      end
    end
  end

  def create
    @private_lesson = PrivateLesson.new(private_lesson_params)
    
    # Set defaults based on user role and form data
    if current_user.student?
      @private_lesson.student = current_user
      @private_lesson.status = 'requested'
    elsif current_user.instructor?
      @private_lesson.instructor = current_user
      @private_lesson.status = 'scheduled'
      # For instructors, student must be selected from form
      if params[:private_lesson][:student_id].present?
        @private_lesson.student_id = params[:private_lesson][:student_id]
      end
    elsif current_user.admin?
      @private_lesson.status = 'scheduled'
      # For admins, both instructor and student can be selected from form
      if params[:private_lesson][:student_id].present?
        @private_lesson.student_id = params[:private_lesson][:student_id]
      end
    end
    
    # Calculate cost based on instructor rates and lesson duration
    if @private_lesson.instructor.present?
      @private_lesson.cost = calculate_lesson_cost(@private_lesson)
    end

    if @private_lesson.save
      # Send notification email to relevant parties
      send_lesson_notification
      
      redirect_to @private_lesson, notice: 'Private lesson was successfully created.'
    else
      # If coming from available_slots, redirect back with error
      if request.referer&.include?('available_slots')
        flash[:alert] = "Unable to book lesson: #{@private_lesson.errors.full_messages.join(', ')}"
        redirect_to available_slots_private_lessons_path(
          instructor_id: @private_lesson.instructor_id,
          student_id: params[:private_lesson][:student_id],
          duration: @private_lesson.duration,
          date: @private_lesson.scheduled_at&.to_date,
          location_id: @private_lesson.location_id
        )
      else
        set_form_data
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    set_form_data
  end

  def update
    if @private_lesson.update(private_lesson_params)
      # Recalculate cost if instructor or duration changed
      if @private_lesson.saved_change_to_instructor_id? || @private_lesson.saved_change_to_duration?
        @private_lesson.update(cost: calculate_lesson_cost(@private_lesson))
      end
      
      redirect_to @private_lesson, notice: 'Private lesson was successfully updated.'
    else
      set_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @private_lesson.destroy!
    redirect_to private_lessons_path, notice: 'Private lesson was successfully deleted.'
  end

  def cancel
    if @private_lesson.can_be_cancelled?
      @private_lesson.update(status: 'cancelled', cancelled_at: Time.current)
      
      redirect_to @private_lesson, notice: 'Private lesson was successfully cancelled.'
    else
      redirect_to @private_lesson, alert: 'This lesson cannot be cancelled (less than 24 hours notice).'
    end
  end

  def confirm
    if current_user.instructor? || current_user.admin?
      @private_lesson.update(status: 'scheduled', confirmed_at: Time.current)
      redirect_to @private_lesson, notice: 'Private lesson was confirmed.'
    else
      redirect_to @private_lesson, alert: 'You are not authorized to confirm lessons.'
    end
  end

  private

  def set_private_lesson
    @private_lesson = PrivateLesson.find(params[:id])
  end

  def ensure_authorized
    unless can_modify_lesson?
      redirect_to private_lessons_path, alert: 'You are not authorized to perform this action.'
    end
  end

  def can_modify_lesson?
    return true if current_user.admin?
    return true if current_user == @private_lesson.instructor
    return true if current_user == @private_lesson.student && @private_lesson.status == 'requested'
    false
  end

  def private_lesson_params
    params.require(:private_lesson).permit(:student_id, :instructor_id, :location_id, :scheduled_at, :duration, :notes, :status)
  end

  def set_form_data
    @students = User.students.order(:first_name, :last_name)
    @instructors = User.instructors.order(:first_name, :last_name)
    @locations = Location.all.order(:name)
    # Removed dance_styles and dance_levels from form data
  end

  def calculate_lesson_cost(lesson)
    return 0 unless lesson.instructor && lesson.duration
    
    # Base rate from instructor (you might want to add this field to User model)
    base_rate = lesson.instructor.hourly_rate || 100 # Default $100/hour
    duration_hours = lesson.duration / 60.0
    
    (base_rate * duration_hours).round(2)
  end

  def calculate_available_slots(instructor, date, duration_minutes)
    # Convert the date to the proper timezone boundaries
    start_of_day = date.beginning_of_day.in_time_zone
    end_of_day = date.end_of_day.in_time_zone
    
    # Get instructor's availability for the date
    availabilities = instructor.instructor_availabilities
                              .where('start_time >= ? AND start_time <= ?', start_of_day.utc, end_of_day.utc)
                              .order(:start_time)
    
    # Get existing bookings for the date
    existing_bookings = PrivateLesson.where(instructor: instructor)
                                   .where('scheduled_at >= ? AND scheduled_at <= ?', start_of_day.utc, end_of_day.utc)
                                   .where(status: ['scheduled', 'requested'])
    
    available_slots = []
    
    availabilities.each do |availability|
      # Convert UTC times to local timezone for calculation
      local_start = availability.start_time.in_time_zone
      local_end = availability.end_time.in_time_zone
      
      # Only process if this availability is on the requested date
      next unless local_start.to_date == date
      
      # Generate 15-minute slots within this availability window
      current_time = local_start
      end_boundary = local_end - duration_minutes.minutes
      
      while current_time <= end_boundary
        slot_end = current_time + duration_minutes.minutes
        
        # Check if this slot conflicts with existing bookings
        conflict = existing_bookings.any? do |booking|
          booking_local_start = booking.scheduled_at.in_time_zone
          booking_local_end = booking_local_start + booking.duration.minutes
          # Check for overlap
          (current_time < booking_local_end) && (slot_end > booking_local_start)
        end
        
        unless conflict
          available_slots << {
            start_time: current_time.utc, # Store as UTC for form submission
            end_time: slot_end.utc,
            formatted_time: current_time.strftime("%I:%M %p"),
            formatted_end: slot_end.strftime("%I:%M %p")
          }
        end
        
        # Move to next 15-minute slot
        current_time += 15.minutes
      end
    end
    
    available_slots
  end

  def get_available_dates(instructor, duration_minutes)
    # Get instructor availabilities for the next 30 days
    start_date = Date.current
    end_date = start_date + 30.days
    
    availabilities = instructor.instructor_availabilities
                              .where('start_time >= ? AND start_time <= ?', 
                                     start_date.beginning_of_day.utc, 
                                     end_date.end_of_day.utc)
    
    # Get existing bookings for the period
    existing_bookings = PrivateLesson.where(instructor: instructor)
                                   .where('scheduled_at >= ? AND scheduled_at <= ?', 
                                          start_date.beginning_of_day.utc, 
                                          end_date.end_of_day.utc)
                                   .where(status: ['scheduled', 'requested'])
    
    available_dates = Set.new
    
    availabilities.each do |availability|
      local_start = availability.start_time.in_time_zone
      local_end = availability.end_time.in_time_zone
      availability_date = local_start.to_date
      
      # Check if this availability can accommodate the requested duration
      if (local_end - local_start) >= duration_minutes.minutes
        # Check if there are any time slots available on this date
        current_time = local_start
        end_boundary = local_end - duration_minutes.minutes
        
        while current_time <= end_boundary
          slot_end = current_time + duration_minutes.minutes
          
          # Check if this slot conflicts with existing bookings
          conflict = existing_bookings.any? do |booking|
            booking_local_start = booking.scheduled_at.in_time_zone
            booking_local_end = booking_local_start + booking.duration.minutes
            # Check for overlap
            (current_time < booking_local_end) && (slot_end > booking_local_start)
          end
          
          unless conflict
            available_dates.add(availability_date)
            break # Found at least one available slot for this date
          end
          
          current_time += 15.minutes
        end
      end
    end
    
    available_dates.to_a.sort
  end

  def send_lesson_notification
    # Add email notification logic here
    # PrivateLessonMailer.lesson_created(@private_lesson).deliver_later
  end
end
