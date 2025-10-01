class RenameDurationMinutesToDuration < ActiveRecord::Migration[7.2]
  def change
    rename_column :private_lessons, :duration_minutes, :duration
  end
end
