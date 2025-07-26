class CreateStudentProgresses < ActiveRecord::Migration[7.2]
  def change
    create_table :student_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :figure, null: false, foreign_key: true
      t.boolean :movement_passed
      t.boolean :timing_passed
      t.boolean :partnering_passed
      t.datetime :completed_at
      t.references :instructor, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
