class FigureCreationService
  def initialize(figure, current_user)
    @figure = figure
    @current_user = current_user
  end

  def call
    return false unless @figure.valid?
    
    ActiveRecord::Base.transaction do
      @figure.save!
      create_progress_records_for_enrolled_students if should_auto_enroll?
      log_creation_activity
    end
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def should_auto_enroll?
    # Auto-enroll students who are already enrolled in this style/level
    true
  end

  def create_progress_records_for_enrolled_students
    # Find students who have progress in this style/level
    enrolled_students = User.students
                           .joins(:student_progresses)
                           .joins("JOIN figures ON figures.id = student_progresses.figure_id")
                           .where(figures: { 
                             dance_style_id: @figure.dance_style_id,
                             dance_level_id: @figure.dance_level_id 
                           })
                           .distinct

    enrolled_students.find_each do |student|
      next if student.student_progresses.exists?(figure: @figure)
      
      student.student_progresses.create!(
        figure: @figure,
        instructor: @current_user,
        movement_passed: false,
        timing_passed: false,
        partnering_passed: false,
        notes: "Auto-enrolled when figure was added to #{@figure.dance_style.name} #{@figure.dance_level.name}"
      )
    end
  end

  def log_creation_activity
    # Log the figure creation if activity logging is implemented
    # ActivityLog.create(
    #   user: @current_user,
    #   action: 'figure_created',
    #   target: @figure,
    #   notes: "Created figure: #{@figure.name}"
    # )
  end
end
