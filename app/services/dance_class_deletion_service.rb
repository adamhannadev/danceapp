class DanceClassDeletionService
  def initialize(dance_class, current_user)
    @dance_class = dance_class
    @current_user = current_user
  end

  def call
    return false unless can_delete?
    
    ActiveRecord::Base.transaction do
      cancel_future_schedules
      refund_payments if has_payments?
      notify_enrolled_students
      @dance_class.destroy!
      log_deletion_activity
    end
    
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::DeleteRestrictionError
    false
  end

  private

  def can_delete?
    # Business logic to determine if class can be deleted
    # For example, don't delete if there are upcoming schedules with bookings
    return true unless has_future_bookings?
    
    # Allow deletion if it's far enough in advance
    earliest_booking = @dance_class.class_schedules
                                  .joins(:bookings)
                                  .where('start_datetime > ?', Time.current)
                                  .minimum(:start_datetime)
    
    return true if earliest_booking.nil?
    
    # Require at least 48 hours notice
    earliest_booking > 48.hours.from_now
  end

  def has_future_bookings?
    @dance_class.class_schedules
                .joins(:bookings)
                .where('start_datetime > ?', Time.current)
                .exists?
  end

  def has_payments?
    # Check if there are payments associated with this class
    # This would depend on your payment model structure
    false
  end

  def cancel_future_schedules
    @dance_class.class_schedules
                .where('start_datetime > ?', Time.current)
                .update_all(status: 'cancelled', cancelled_at: Time.current)
  end

  def refund_payments
    # Handle payment refunds if necessary
    # This would depend on your payment processing system
  end

  def notify_enrolled_students
    # Send notifications to students about class cancellation
    # This would depend on your notification system
  end

  def log_deletion_activity
    # Log the class deletion if activity logging is implemented
    # ActivityLog.create(
    #   user: @current_user,
    #   action: 'dance_class_deleted',
    #   notes: "Deleted class: #{@dance_class.name}"
    # )
  end
end
