class AddGoalsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :goals, :text
  end
end
