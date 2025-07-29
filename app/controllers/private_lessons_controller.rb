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
  end

  def new
    @private_lesson = PrivateLesson.new
    set_form_data
  end

  def create
    @private_lesson = PrivateLesson.new(private_lesson_params)
    
    # Set defaults based on user role
    if current_user.student?
      @private_lesson.student = current_user
      @private_lesson.status = 'requested'
    elsif current_user.instructor?
      @private_lesson.instructor = current_user
      @private_lesson.status = 'scheduled'
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
      set_form_data
      render :new, status: :unprocessable_entity
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
    params.require(:private_lesson).permit(:student_id, :instructor_id, :location_id, :scheduled_at, :duration, :notes, :status, :cost)
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
    total_cost = base_rate * duration_hours
    
    # Apply membership discount if student has one
    if lesson.student&.membership_type != 'none'
      discount = lesson.student.membership_discount / 100.0
      total_cost *= (1 - discount)
    end
    
    total_cost.round(2)
  end

  def send_lesson_notification
    # Add email notification logic here
    # PrivateLessonMailer.lesson_created(@private_lesson).deliver_later
  end
end
