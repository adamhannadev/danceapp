class UpdatePrivateLessonsColumns < ActiveRecord::Migration[7.2]
  def change
    # Rename columns to match model expectations
    rename_column :private_lessons, :duration_minutes, :duration
    rename_column :private_lessons, :price, :cost
    
    # Add missing columns
    add_column :private_lessons, :focus_areas, :text
    add_column :private_lessons, :confirmed_at, :datetime
    add_column :private_lessons, :cancelled_at, :datetime
    
    # Add default status if not present
    change_column_default :private_lessons, :status, 'requested'
    
    # Add precision to cost column
    change_column :private_lessons, :cost, :decimal, precision: 8, scale: 2
  end
end
