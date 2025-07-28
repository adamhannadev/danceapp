class RemoveDanceStyleFromDanceLevels < ActiveRecord::Migration[7.2]
  def up
    # Check if we need to do anything - if simplified levels already exist, skip
    bronze_1_exists = execute("SELECT COUNT(*) as count FROM dance_levels WHERE name = 'Bronze 1'").first['count'].to_i > 0
    
    if bronze_1_exists
      puts "Simplified dance levels already exist, skipping migration"
      return
    end
    
    # Check if dance_style_id column exists before trying to remove it
    if column_exists?(:dance_levels, :dance_style_id)
      # Remove foreign key constraint from dance_levels to dance_styles
      if foreign_key_exists?(:dance_levels, :dance_styles)
        remove_foreign_key :dance_levels, :dance_styles
      end
      
      # Get all existing dance levels to create mapping
      existing_levels = execute("SELECT id, name, level_number, dance_style_id FROM dance_levels ORDER BY id")
      
      # Remove the dance_style_id column from dance_levels
      remove_column :dance_levels, :dance_style_id
    end
    
    # Store existing level mappings for foreign key updates
    level_mappings = {}
    existing_levels_result = execute("SELECT id, name FROM dance_levels ORDER BY id")
    existing_levels_result.each do |level|
      # Map existing levels to new simplified levels based on name patterns
      old_id = level['id']
      old_name = level['name']
      
      new_name = case old_name
                when /Bronze.*1/i then 'Bronze 1'
                when /Bronze.*2/i then 'Bronze 2'
                when /Bronze.*3/i then 'Bronze 3'
                when /Bronze.*4/i then 'Bronze 4'
                when /Silver.*1/i then 'Silver 1'
                when /Silver.*2/i then 'Silver 2'
                when /Silver.*3/i then 'Silver 3'
                when /Silver.*4/i then 'Silver 4'
                when /Gold.*1/i then 'Gold 1'
                when /Gold.*2/i then 'Gold 2'
                when /Gold.*3/i then 'Gold 3'
                when /Gold.*4/i then 'Gold 4'
                else 'Bronze 1'
                end
      
      level_mappings[old_id] = new_name
    end
    
    # Clear existing dance levels 
    execute("DELETE FROM dance_levels")
    
    # Create the new simplified global levels
    level_data = [
      { name: 'Bronze 1', number: 1 },
      { name: 'Bronze 2', number: 2 },
      { name: 'Bronze 3', number: 3 },
      { name: 'Bronze 4', number: 4 },
      { name: 'Silver 1', number: 5 },
      { name: 'Silver 2', number: 6 },
      { name: 'Silver 3', number: 7 },
      { name: 'Silver 4', number: 8 },
      { name: 'Gold 1', number: 9 },
      { name: 'Gold 2', number: 10 },
      { name: 'Gold 3', number: 11 },
      { name: 'Gold 4', number: 12 }
    ]
    
    level_data.each do |level_info|
      execute("INSERT INTO dance_levels (name, level_number, description, created_at, updated_at) VALUES ('#{level_info[:name]}', #{level_info[:number]}, '#{level_info[:name]} difficulty level', NOW(), NOW())")
    end
    
    # Update foreign key references in other tables to map to simplified levels
    level_mappings.each do |old_id, new_name|
      new_id = execute("SELECT id FROM dance_levels WHERE name = '#{new_name}' LIMIT 1").first['id']
      
      # Update figures table
      execute("UPDATE figures SET dance_level_id = #{new_id} WHERE dance_level_id = #{old_id}")
      
      # Update dance_classes table
      execute("UPDATE dance_classes SET dance_level_id = #{new_id} WHERE dance_level_id = #{old_id}")
      
      # Update private_lessons table if it exists
      if table_exists?(:private_lessons)
        execute("UPDATE private_lessons SET dance_level_id = #{new_id} WHERE dance_level_id = #{old_id}")
      end
      
      # Update student_progresses table if it exists
      if table_exists?(:student_progresses)
        execute("UPDATE student_progresses SET dance_level_id = #{new_id} WHERE dance_level_id = #{old_id}")
      end
    end
    
    # Add name uniqueness constraint if it doesn't exist
    unless index_exists?(:dance_levels, :name, unique: true)
      add_index :dance_levels, :name, unique: true
    end
  end

  def down
    # Remove the unique name index if it exists
    if index_exists?(:dance_levels, :name, unique: true)
      remove_index :dance_levels, :name
    end
    
    # Add back the dance_style_id column if it doesn't exist
    unless column_exists?(:dance_levels, :dance_style_id)
      add_column :dance_levels, :dance_style_id, :bigint
    end
    
    # Add back foreign key constraint if dance_styles table exists
    if table_exists?(:dance_styles)
      add_foreign_key :dance_levels, :dance_styles
      
      # Re-create style-specific levels (this is a simplified version)
      # In a real rollback, you might want to preserve the original data structure
      execute("DELETE FROM dance_levels")
      
      DanceStyle.find_each do |style|
        level_data = [
          { name: 'Bronze 1', number: 1 },
          { name: 'Bronze 2', number: 2 },
          { name: 'Bronze 3', number: 3 },
          { name: 'Bronze 4', number: 4 },
          { name: 'Silver 1', number: 5 },
          { name: 'Silver 2', number: 6 },
          { name: 'Silver 3', number: 7 },
          { name: 'Silver 4', number: 8 },
          { name: 'Gold 1', number: 9 },
          { name: 'Gold 2', number: 10 },
          { name: 'Gold 3', number: 11 },
          { name: 'Gold 4', number: 12 }
        ]
        
        level_data.each do |level_info|
          execute("INSERT INTO dance_levels (name, level_number, dance_style_id, description, created_at, updated_at) VALUES ('#{level_info[:name]}', #{level_info[:number]}, #{style.id}, '#{level_info[:name]}', NOW(), NOW())")
        end
      end
    else
      puts "Warning: dance_styles table does not exist, cannot fully rollback migration"
    end
  end
end
