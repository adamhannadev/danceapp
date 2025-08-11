class StudentProgressDetailService
  def initialize(student_progress)
    @student_progress = student_progress
  end

  def call
    {
      figure: @student_progress.figure,
      dance_style: @student_progress.figure.dance_style,
      dance_level: @student_progress.figure.dance_level,
      instructor: @student_progress.instructor,
      completion_status: completion_status
    }
  end

  private

  def completion_status
    {
      movement_passed: @student_progress.movement_passed?,
      timing_passed: @student_progress.timing_passed?,
      partnering_passed: @student_progress.partnering_passed?,
      completed: @student_progress.completed?,
      completion_percentage: @student_progress.completion_percentage
    }
  end
end
