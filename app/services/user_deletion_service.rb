class UserDeletionService
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  def call
    return false unless can_delete?
    
    ActiveRecord::Base.transaction do
      cleanup_user_data
      @user.destroy!
      log_deletion_activity
    end
    
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::DeleteRestrictionError
    false
  end

  private

  def can_delete?
    # Add business logic for when a user can be deleted
    # For example, don't delete if they have upcoming lessons
    upcoming_lessons = @user.private_lessons_as_student.where('scheduled_at > ?', Time.current)
    upcoming_lessons.empty?
  end

  def cleanup_user_data
    # Clean up associated data before deletion
    @user.student_progresses.destroy_all
    cancel_future_lessons
    remove_from_waitlists
  end

  def cancel_future_lessons
    @user.private_lessons_as_student
         .where('scheduled_at > ?', Time.current)
         .update_all(status: 'cancelled', cancelled_at: Time.current)
  end

  def remove_from_waitlists
    # Remove from any waitlists if that model exists
    # @user.waitlist_entries.destroy_all if defined?(WaitlistEntry)
  end

  def log_deletion_activity
    # Log activity if activity logging is implemented
    # ActivityLog.create(user: @current_user, action: 'user_deleted', notes: "Deleted user: #{@user.full_name}")
  end
end
