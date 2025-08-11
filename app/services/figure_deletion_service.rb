class FigureDeletionService
  def initialize(figure, current_user)
    @figure = figure
    @current_user = current_user
  end

  def call
    return false unless can_delete?
    
    ActiveRecord::Base.transaction do
      cleanup_student_progress
      @figure.destroy!
      log_deletion_activity
    end
    
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::DeleteRestrictionError
    false
  end

  private

  def can_delete?
    # Check if figure has any student progress records
    # In some cases, you might want to prevent deletion if students have progress
    
    progress_count = @figure.student_progresses.count
    
    # Allow deletion only if no progress exists, or all progress is very recent (< 1 day)
    return true if progress_count.zero?
    
    # Check if all progress is recent and can be safely removed
    recent_cutoff = 1.day.ago
    old_progress_count = @figure.student_progresses.where('created_at < ?', recent_cutoff).count
    
    old_progress_count.zero?
  end

  def cleanup_student_progress
    # Remove all student progress records for this figure
    @figure.student_progresses.destroy_all
  end

  def log_deletion_activity
    # Log the figure deletion if activity logging is implemented
    # ActivityLog.create(
    #   user: @current_user,
    #   action: 'figure_deleted',
    #   notes: "Deleted figure: #{@figure.name} (#{@figure.dance_style.name} #{@figure.dance_level.name})"
    # )
  end
end
