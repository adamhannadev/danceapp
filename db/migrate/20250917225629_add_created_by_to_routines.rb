class AddCreatedByToRoutines < ActiveRecord::Migration[7.2]
  def change
    # Add the column without null constraint first
    add_reference :routines, :created_by, foreign_key: { to_table: :users }
    
    # Set created_by_id to user_id for existing routines (assuming user_id is the creator for existing routines)
    execute "UPDATE routines SET created_by_id = user_id WHERE created_by_id IS NULL"
    
    # Now add the null constraint
    change_column_null :routines, :created_by_id, false
  end
end
