class RemoveDanceStyleFromDanceLevels < ActiveRecord::Migration[7.2]
  def up
    # Remove foreign key constraint from dance_levels to dance_styles
    if foreign_key_exists?(:dance_levels, :dance_styles)
      remove_foreign_key :dance_levels, :dance_styles
    end
    
    # First, we need to handle the foreign key references from other tables
    # Let's update figures to point to new simplified levels
    
    # Get all existing dance levels to create mapping
    existing_levels = execute("SELECT id, name, level_number, dance_style_id FROM dance_levels ORDER BY id")
    
    # Clear existing dance levels (this will require temporarily disabling foreign key checks)
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
    
    # Update foreign key references in other tables
    # For figures, map based on level name pattern
    execute(<<~SQL)
      UPDATE figures 
      SET dance_level_id = (
        SELECT id FROM dance_levels 
        WHERE dance_levels.name LIKE 
          CASE 
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Bronze 1%') THEN 'Bronze 1'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Bronze 2%') THEN 'Bronze 2'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Bronze 3%') THEN 'Bronze 3'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Bronze 4%') THEN 'Bronze 4'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Silver 1%') THEN 'Silver 1'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Silver 2%') THEN 'Silver 2'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Silver 3%') THEN 'Silver 3'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Silver 4%') THEN 'Silver 4'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Gold 1%') THEN 'Gold 1'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Gold 2%') THEN 'Gold 2'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Gold 3%') THEN 'Gold 3'
            WHEN figures.dance_level_id IN (SELECT id FROM dance_levels WHERE name LIKE 'Gold 4%') THEN 'Gold 4'
            ELSE 'Bronze 1'
          END
        LIMIT 1
      )
    SQL
    
    # Remove the dance_style_id column from dance_levels
    remove_column :dance_levels, :dance_style_id
    
    # Update name uniqueness constraint
    add_index :dance_levels, :name, unique: true
  end

  def down
    # Add back the dance_style_id column
    add_column :dance_levels, :dance_style_id, :bigint
    
    # Remove the unique name index
    remove_index :dance_levels, :name
    
    # Add back foreign key constraint
    add_foreign_key :dance_levels, :dance_styles
    
    # Re-create style-specific levels (this is a simplified version)
    # In a real rollback, you might want to preserve the original data structure
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
  end
end
