class FigureUpdateService
  def initialize(figure, params, current_user)
    @figure = figure
    @params = params
    @current_user = current_user
  end

  def call
    return false unless @figure.update(@params)
    
    handle_style_level_change if style_or_level_changed?
    log_update_activity
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def style_or_level_changed?
    @figure.saved_change_to_dance_style_id? || @figure.saved_change_to_dance_level_id?
  end

  def handle_style_level_change
    # When style/level changes, we might need to update student progress records
    # or notify instructors about the change
    notify_instructors_of_change
  end

  def notify_instructors_of_change
    # Notify instructors who have students working on this figure
    affected_instructors = User.joins(:student_progresses_as_instructor)
                              .where(student_progresses: { figure: @figure })
                              .distinct

    # Send notifications (would depend on your notification system)
    # affected_instructors.each do |instructor|
    #   FigureChangeNotificationMailer.style_level_changed(@figure, instructor).deliver_later
    # end
  end

  def log_update_activity
    # Log the figure update if activity logging is implemented
    # ActivityLog.create(
    #   user: @current_user,
    #   action: 'figure_updated',
    #   target: @figure,
    #   notes: "Updated figure: #{@figure.name}"
    # )
  end
end
