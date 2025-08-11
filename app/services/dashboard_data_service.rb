class DashboardDataService
  def initialize(user)
    @user = user
  end

  def call
    case @user.role
    when 'admin'
      admin_dashboard_data
    when 'instructor'
      instructor_dashboard_data
    else
      student_dashboard_data
    end
  end

  private

  def admin_dashboard_data
    {
      students: User.students.includes(:student_progresses, :private_lessons_as_student).limit(20),
      private_lessons: PrivateLesson.includes(:student, :instructor).order(scheduled_at: :desc).limit(10),
      dance_classes: DanceClass.includes(:instructor, :dance_style).order(:name).limit(10),
      instructors: User.instructors.includes(:dance_classes),
      stats: admin_stats
    }
  end

  def instructor_dashboard_data
    {
      students: instructor_students.includes(:student_progresses).order(:first_name, :last_name).limit(15),
      private_lessons: @user.private_lessons_as_instructor.includes(:student).order(scheduled_at: :desc).limit(10),
      dance_classes: @user.dance_classes.includes(:dance_style).order(:name).limit(10),
      today_lessons: @user.private_lessons_as_instructor.on_date(Date.current).includes(:student),
      stats: instructor_stats
    }
  end

  def student_dashboard_data
    {
      private_lessons: @user.private_lessons_as_student.includes(:instructor).order(scheduled_at: :desc).limit(10),
      enrolled_classes: enrolled_classes_for_student,
      progress: @user.student_progresses.includes(:figure).order(updated_at: :desc).limit(5),
      available_classes: available_classes_for_student,
      stats: student_stats
    }
  end

  def admin_stats
    {
      total_students: User.students.count,
      total_instructors: User.instructors.count,
      total_classes: DanceClass.count,
      monthly_revenue: calculate_monthly_revenue
    }
  end

  def instructor_stats
    {
      total_students: instructor_students.count,
      classes_this_week: @user.dance_classes.count, # Simplified since we don't have this_week scope
      lessons_this_week: @user.private_lessons_as_instructor.this_week.count
    }
  end

  def student_stats
    progress_data = @user.student_progresses
    {
      total_figures: progress_data.count,
      completed_figures: progress_data.where('completed_at IS NOT NULL').count,
      current_level: current_dance_level_name,
      completion_percentage: calculate_completion_percentage(progress_data)
    }
  end

  def instructor_students
    # Get students who have lessons with this instructor
    User.joins(:private_lessons_as_student)
        .where(private_lessons: { instructor_id: @user.id })
        .distinct
  end

  def enrolled_classes_for_student
    # Get classes through bookings if that association exists
    return DanceClass.none unless @user.student?
    
    # For now, return empty relation since we need to check the booking model structure
    DanceClass.none
  end

  def available_classes_for_student
    return DanceClass.none unless @user.student?
    
    # Simple implementation - show all classes for now
    DanceClass.includes(:instructor, :dance_style).limit(6)
  end

  def current_dance_level_name
    # This would need to be implemented based on your business logic
    # For now, return a default
    'Beginner'
  end

  def calculate_monthly_revenue
    # Simple monthly revenue calculation - would need Payment model implementation
    if defined?(Payment)
      Payment.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).sum(:amount)
    else
      0
    end
  end

  def calculate_completion_percentage(progress_data)
    total = progress_data.count
    return 0 if total.zero?
    
    completed = progress_data.where('completed_at IS NOT NULL').count
    (completed.to_f / total * 100).round(1)
  end
end
