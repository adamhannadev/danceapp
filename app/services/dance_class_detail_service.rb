class DanceClassDetailService
  def initialize(dance_class, current_user)
    @dance_class = dance_class
    @current_user = current_user
  end

  def call
    {
      class_schedules: @dance_class.class_schedules.includes(:bookings),
      upcoming_schedules: upcoming_schedules,
      can_enroll: can_enroll?,
      enrollment_info: enrollment_info
    }
  end

  private

  def upcoming_schedules
    @dance_class.class_schedules
                .where('start_datetime > ?', Time.current)
                .order(:start_datetime)
                .limit(5)
  end

  def can_enroll?
    return false unless @current_user&.student?
    
    # Basic enrollment check - can be enhanced based on business rules
    true
  end

  def enrollment_info
    return {} unless @current_user&.student?
    
    {
      is_enrolled: false, # This would need to be implemented based on your booking system
      spots_available: @dance_class.max_capacity, # Simplified - would need actual booking count
      waitlist_position: nil # Would need waitlist implementation
    }
  end
end
