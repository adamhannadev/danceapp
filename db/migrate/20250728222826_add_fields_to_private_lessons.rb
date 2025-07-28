class AddFieldsToPrivateLessons < ActiveRecord::Migration[7.2]
  def change
    add_column :private_lessons, :focus_areas, :text
    add_column :private_lessons, :confirmed_at, :datetime
    add_column :private_lessons, :cancelled_at, :datetime
  end
end
