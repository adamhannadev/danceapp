class UpdatePrivateLessonsColumns < ActiveRecord::Migration[7.2]
  def change
    
    # Add default status if not present
    change_column_default :private_lessons, :status, 'requested'
    
    # Add precision to cost column
    change_column :private_lessons, :cost, :decimal, precision: 8, scale: 2
  end
end
