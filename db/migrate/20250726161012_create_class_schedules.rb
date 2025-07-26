class CreateClassSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :class_schedules do |t|
      t.references :dance_class, null: false, foreign_key: true
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.boolean :recurring
      t.text :recurrence_pattern
      t.boolean :active

      t.timestamps
    end
  end
end
