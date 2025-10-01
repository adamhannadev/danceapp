class UserRegistrationService
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  def call
    return false unless @user.valid?
    
    ActiveRecord::Base.transaction do
      # Create user without triggering Devise callbacks that might affect session
      @user.save!
      
      setup_default_progress if @user.student?
      send_welcome_notification
      log_registration_activity
    end
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def setup_default_progress
    # Create default progress records for beginner level figures
    beginner_level = DanceLevel.find_by(name: 'Beginner') || DanceLevel.order(:level_number).first
    return unless beginner_level
    
    beginner_figures = Figure.where(dance_level: beginner_level, is_core: true)
    
    beginner_figures.find_each do |figure|
      @user.student_progresses.create!(
        figure: figure,
        instructor: @current_user,
        movement_passed: false,
        timing_passed: false,
        partnering_passed: false,
        notes: "Enrolled in #{figure.dance_style.name}"
      )
    end
  end

  def send_welcome_notification
    # Send welcome email if mailer is configured
    # UserMailer.welcome_email(@user).deliver_later if defined?(UserMailer)
  end

  def log_registration_activity
    # Log activity if activity logging is implemented
    # ActivityLog.create(user: @current_user, action: 'user_created', target: @user)
  end
end
