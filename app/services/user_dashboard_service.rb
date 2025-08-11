class UserDashboardService
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  def call
    case @user.role
    when 'student'
      student_dashboard_data
    when 'instructor'
      instructor_dashboard_data
    else
      basic_user_data
    end
  end

  private

  def student_dashboard_data
    {
      recent_progress: @user.student_progresses.includes(:figure)
                           .order(updated_at: :desc).limit(5),
      upcoming_bookings: upcoming_bookings,
      enrollment_stats: enrollment_stats
    }
  end

  def instructor_dashboard_data
    data = {
      teaching_classes: @user.dance_classes.includes(:dance_style, :dance_level).limit(5)
    }
    
    # Add availability data if user can access it
    if can_view_instructor_availability?
      data.merge!(instructor_availability_data)
    end
    
    data
  end

  def basic_user_data
    {
      basic_info: true
    }
  end

  def upcoming_bookings
    return [] unless @user.student?
    
    @user.bookings.includes(:class_schedule)
        .joins(:class_schedule)
        .where('class_schedules.start_datetime > ?', Time.current)
        .order('class_schedules.start_datetime')
        .limit(5)
  end

  def enrollment_stats
    return {} unless @user.student?
    
    progresses = @user.student_progresses
    {
      total_figures: progresses.count,
      completed_figures: progresses.where('completed_at IS NOT NULL').count,
      completion_percentage: calculate_completion_percentage(progresses)
    }
  end

  def instructor_availability_data
    {
      instructor_availabilities: @user.instructor_availabilities.includes(:location)
                                      .order(:start_time).limit(10),
      upcoming_availabilities: @user.instructor_availabilities.includes(:location)
                                   .where('start_time >= ?', Time.current)
                                   .order(:start_time).limit(6)
    }
  end

  def can_view_instructor_availability?
    @user.instructor? && (@current_user&.admin? || @current_user == @user)
  end

  def calculate_completion_percentage(progresses)
    total = progresses.count
    return 0 if total.zero?
    
    completed = progresses.where('completed_at IS NOT NULL').count
    (completed.to_f / total * 100).round(1)
  end
end
