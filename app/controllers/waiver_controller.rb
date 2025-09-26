class WaiverController < ApplicationController
  
  def show
    # This could be used for a standalone waiver page if needed
    render json: { content: waiver_content }
  end
  
  def sign
    user_id = params[:user_id]
    
    # Handle different scenarios
    if user_id.present?
      # Signing for a specific user (admins/teachers updating for others)
      user = User.find(user_id)
      
      # Check permissions - only admins and instructors can sign for others
      unless current_user&.admin? || current_user&.instructor? || current_user == user
        return render json: { 
          success: false, 
          message: 'You do not have permission to sign for this user.' 
        }, status: :forbidden
      end
      
      sign_waiver_for_user(user)
      
    elsif current_user
      # Current user signing their own waiver
      sign_waiver_for_user(current_user)
      
    else
      # Registration flow - just acknowledge the signing (will be saved when user is created)
      render json: { 
        success: true, 
        message: 'Waiver acknowledged for registration!',
        signed_at: Time.current.strftime("%B %d, %Y at %I:%M %p")
      }
    end
  end
  
  private
  
  def sign_waiver_for_user(user)
    begin
      user.update!(
        waiver_signed: true,
        waiver_signed_at: Time.current
      )
      
      render json: { 
        success: true, 
        message: 'Waiver signed successfully!',
        signed_at: user.waiver_signed_at.strftime("%B %d, %Y at %I:%M %p")
      }
    rescue => e
      Rails.logger.error "Failed to sign waiver for user #{user.id}: #{e.message}"
      render json: { 
        success: false, 
        message: 'Failed to sign waiver. Please try again.' 
      }, status: :unprocessable_entity
    end
  end
  
  def waiver_content
    File.read(Rails.root.join('waiver.txt'))
  end
end