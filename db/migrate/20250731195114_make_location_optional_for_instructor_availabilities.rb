class MakeLocationOptionalForInstructorAvailabilities < ActiveRecord::Migration[7.2]
  def change
    change_column_null :instructor_availabilities, :location_id, true
  end
end
