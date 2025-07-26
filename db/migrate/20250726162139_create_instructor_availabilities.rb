class CreateInstructorAvailabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :instructor_availabilities do |t|
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.references :location, null: false, foreign_key: true
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time
      t.boolean :active

      t.timestamps
    end
  end
end
