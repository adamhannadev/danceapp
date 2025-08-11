class DanceClassUpdateService
  def initialize(dance_class, params, current_user)
    @dance_class = dance_class
    @params = params
    @current_user = current_user
  end

  def call
    return false unless @dance_class.update(@params)
    
    handle_instructor_change if instructor_changed?
    update_related_schedules if schedule_affecting_changes?
    log_update_activity
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def instructor_changed?
    @dance_class.saved_change_to_instructor_id?
  end

  def schedule_affecting_changes?
    @dance_class.saved_change_to_duration_minutes? || 
    @dance_class.saved_change_to_location_id?
  end

  def handle_instructor_change
    # Notify students of instructor change
    # Update related private lessons if needed
    notify_students_of_instructor_change
  end

  def update_related_schedules
    # Update future class schedules with new duration/location
    future_schedules = @dance_class.class_schedules.where('start_datetime > ?', Time.current)
    
    future_schedules.find_each do |schedule|
      if @dance_class.saved_change_to_duration_minutes?
        schedule.update(duration_minutes: @dance_class.duration_minutes)
      end
      
      if @dance_class.saved_change_to_location_id?
        schedule.update(location_id: @dance_class.location_id)
      end
    end
  end

  def notify_students_of_instructor_change
    # Send notifications to enrolled students
    # This would depend on your notification system
  end

  def log_update_activity
    # Log the class update if activity logging is implemented
    # ActivityLog.create(
    #   user: @current_user,
    #   action: 'dance_class_updated',
    #   target: @dance_class,
    #   notes: "Updated class: #{@dance_class.name}"
    # )
  end
end
