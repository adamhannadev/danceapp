class RenamePrivateLessonsColumns < ActiveRecord::Migration[7.2]
  def change
    rename_column :private_lessons, :duration_minutes, :duration
    rename_column :private_lessons, :price, :cost
  end
end
