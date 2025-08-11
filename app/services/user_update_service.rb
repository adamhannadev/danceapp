class UserUpdateService
  def initialize(user, params, current_user)
    @user = user
    @params = params
    @current_user = current_user
  end

  def call
    return false unless @user.update(@params)
    
    handle_role_change if role_changed?
    log_update_activity
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def role_changed?
    @user.saved_change_to_role?
  end

  def handle_role_change
    case @user.role
    when 'student'
      setup_student_defaults
    when 'instructor'
      setup_instructor_defaults
    end
  end

  def setup_student_defaults
    return if @user.student_progresses.exists?
    
    # Set up basic progress tracking for new students
    UserRegistrationService.new(@user, @current_user).send(:setup_default_progress)
  end

  def setup_instructor_defaults
    # Set up instructor-specific defaults if needed
    # Could include creating availability templates, etc.
  end

  def log_update_activity
    # Log activity if activity logging is implemented
    # ActivityLog.create(user: @current_user, action: 'user_updated', target: @user)
  end
end
