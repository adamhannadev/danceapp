class AddRecurringFieldsToPrivateLessons < ActiveRecord::Migration[7.2]
  def change
    add_column :private_lessons, :is_recurring, :boolean, default: false, null: false
    add_column :private_lessons, :recurrence_rule, :string
    add_column :private_lessons, :parent_lesson_id, :integer
    add_column :private_lessons, :recurring_until, :date
    
    add_index :private_lessons, :parent_lesson_id
    add_index :private_lessons, :is_recurring
    
    add_foreign_key :private_lessons, :private_lessons, column: :parent_lesson_id
  end
end
