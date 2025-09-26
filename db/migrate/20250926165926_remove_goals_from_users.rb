class RemoveGoalsFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :goals, :text
  end
end
