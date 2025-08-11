class StudentProgressMarkingService
  def initialize(student_progress, params)
    @student_progress = student_progress
    @params = params
  end

  def call
    component = @params[:component]
    
    result = case component
    when 'movement'
      toggle_movement
    when 'timing'
      toggle_timing
    when 'partnering'
      toggle_partnering
    when 'reset'
      reset_progress
    else
      { success: false, message: 'Invalid component specified' }
    end
    
    check_completion if result[:success]
    result
  end

  private

  def toggle_movement
    @student_progress.toggle!(:movement_passed)
    success_response('Movement component updated')
  end

  def toggle_timing
    @student_progress.toggle!(:timing_passed)
    success_response('Timing component updated')
  end

  def toggle_partnering
    @student_progress.toggle!(:partnering_passed)
    success_response('Partnering component updated')
  end

  def reset_progress
    @student_progress.update!(
      movement_passed: false,
      timing_passed: false,
      partnering_passed: false,
      completed_at: nil
    )
    
    {
      success: true,
      message: "Progress has been reset for #{@student_progress.figure.name}.",
      completed: false,
      completion_percentage: 0
    }
  end

  def check_completion
    return unless @student_progress.completed? && @student_progress.completed_at.nil?
    
    @student_progress.mark_completed!
  end

  def success_response(message)
    {
      success: true,
      message: message,
      completed: @student_progress.completed?,
      completion_percentage: @student_progress.completion_percentage
    }
  end
end
