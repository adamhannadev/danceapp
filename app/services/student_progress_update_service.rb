class StudentProgressUpdateService
  def initialize(student_progress, params, current_user)
    @student_progress = student_progress
    @params = params
    @current_user = current_user
  end

  def call
    handle_mark_all_request if @params[:mark_all] == 'true'
    
    return false unless @student_progress.update(@params)
    
    check_and_mark_completion
    log_progress_update
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def handle_mark_all_request
    @student_progress.update!(
      movement_passed: true,
      timing_passed: true,
      partnering_passed: true
    )
    
    @student_progress.mark_completed! if @student_progress.completed?
  end

  def check_and_mark_completion
    return unless @student_progress.completed? && @student_progress.completed_at.nil?
    
    @student_progress.mark_completed!
  end

  def log_progress_update
    # Log the progress update if activity logging is implemented
    # ActivityLog.create(
    #   user: @current_user, 
    #   action: 'progress_updated', 
    #   target: @student_progress,
    #   notes: "Updated #{@student_progress.figure.name} progress"
    # )
  end
end
