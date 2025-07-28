class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Require authentication for all actions
  before_action :authenticate_user!
  
  # Configure permitted parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :role, :membership_type, :waiver_signed])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :role, :membership_type, :waiver_signed])
  end
end
