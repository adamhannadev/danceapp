class AddHourlyRateToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :hourly_rate, :decimal, precision: 8, scale: 2, default: 100.00
  end
end
