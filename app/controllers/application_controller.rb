class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Require authentication for all actions
  before_action :authenticate_user!
  
  # Configure permitted parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :role, :membership_type, :membership_discount, :waiver_signed, :goals])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :role, :membership_type, :membership_discount, :waiver_signed, :goals])
  end

  # Authorization helpers
  def ensure_admin!
    redirect_to root_path, alert: 'Access denied. Admin privileges required.' unless current_user&.admin?
  end
  
  def ensure_instructor_or_admin!
    redirect_to root_path, alert: 'Access denied. Instructor or admin privileges required.' unless current_user&.instructor? || current_user&.admin?
  end
  
  def ensure_owns_resource_or_instructor_or_admin!(resource_user)
    unless current_user&.admin? || current_user&.instructor? || current_user == resource_user
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def ensure_can_access_student!(student)
    return if current_user.admin?
    return if current_user.instructor?
    return if current_user == student
    
    redirect_to root_path, alert: 'Access denied.'
  end
end
