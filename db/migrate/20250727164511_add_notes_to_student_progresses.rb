class AddNotesToStudentProgresses < ActiveRecord::Migration[7.2]
  def change
    add_column :student_progresses, :notes, :text
  end
end
