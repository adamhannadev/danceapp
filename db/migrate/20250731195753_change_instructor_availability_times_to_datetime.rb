class ChangeInstructorAvailabilityTimesToDatetime < ActiveRecord::Migration[7.2]
  def up
    # Add new datetime columns
    add_column :instructor_availabilities, :start_datetime, :datetime
    add_column :instructor_availabilities, :end_datetime, :datetime
    
    # Copy existing time data to new datetime columns (set to today for existing data)
    InstructorAvailability.reset_column_information
    InstructorAvailability.find_each do |availability|
      if availability.start_time && availability.end_time
        base_date = Date.current
        availability.update_columns(
          start_datetime: base_date.beginning_of_day + availability.start_time.seconds_since_midnight.seconds,
          end_datetime: base_date.beginning_of_day + availability.end_time.seconds_since_midnight.seconds
        )
      end
    end
    
    # Remove old time columns
    remove_column :instructor_availabilities, :start_time
    remove_column :instructor_availabilities, :end_time
    
    # Rename new columns to match expected names
    rename_column :instructor_availabilities, :start_datetime, :start_time
    rename_column :instructor_availabilities, :end_datetime, :end_time
  end

  def down
    # Add back time columns
    add_column :instructor_availabilities, :start_time_old, :time
    add_column :instructor_availabilities, :end_time_old, :time
    
    # Copy datetime data back to time columns
    InstructorAvailability.reset_column_information
    InstructorAvailability.find_each do |availability|
      if availability.start_time && availability.end_time
        availability.update_columns(
          start_time_old: availability.start_time.strftime('%H:%M:%S'),
          end_time_old: availability.end_time.strftime('%H:%M:%S')
        )
      end
    end
    
    # Remove datetime columns
    remove_column :instructor_availabilities, :start_time
    remove_column :instructor_availabilities, :end_time
    
    # Rename back
    rename_column :instructor_availabilities, :start_time_old, :start_time
    rename_column :instructor_availabilities, :end_time_old, :end_time
  end
end
