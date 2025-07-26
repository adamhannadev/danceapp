class SimplifyDanceLevels < ActiveRecord::Migration[7.2]
  def up
    # Step 1: Update all figures to use the first occurrence of each level
    # (Bronze 1 from any style becomes Bronze 1, etc.)
    
    # Create a mapping of level names to the first ID of that level
    level_mapping = {}
    
    # Get the first occurrence of each level name
    execute(<<~SQL)
      CREATE TEMP TABLE level_mapping AS
      SELECT DISTINCT ON (name) id as new_id, name, level_number
      FROM dance_levels 
      ORDER BY name, id;
    SQL
    
    # Update figures to use the first occurrence of each level
    execute(<<~SQL)
      UPDATE figures 
      SET dance_level_id = (
        SELECT lm.new_id 
        FROM level_mapping lm 
        JOIN dance_levels dl ON dl.id = figures.dance_level_id 
        WHERE lm.name = dl.name
      );
    SQL
    
    # Update dance_classes to use the first occurrence of each level
    execute(<<~SQL)
      UPDATE dance_classes 
      SET dance_level_id = (
        SELECT lm.new_id 
        FROM level_mapping lm 
        JOIN dance_levels dl ON dl.id = dance_classes.dance_level_id 
        WHERE lm.name = dl.name
      );
    SQL
    
    # Update private_lessons to use the first occurrence of each level
    execute(<<~SQL)
      UPDATE private_lessons 
      SET dance_level_id = (
        SELECT lm.new_id 
        FROM level_mapping lm 
        JOIN dance_levels dl ON dl.id = private_lessons.dance_level_id 
        WHERE lm.name = dl.name
      );
    SQL
    
    # Step 2: Remove duplicate dance levels (keep only the first of each name)
    execute(<<~SQL)
      DELETE FROM dance_levels 
      WHERE id NOT IN (SELECT new_id FROM level_mapping);
    SQL
    
    # Step 3: Remove the foreign key constraint and dance_style_id column
    remove_foreign_key :dance_levels, :dance_styles if foreign_key_exists?(:dance_levels, :dance_styles)
    remove_column :dance_levels, :dance_style_id
    
    # Step 4: Add unique constraint on name
    add_index :dance_levels, :name, unique: true
    add_index :dance_levels, :level_number, unique: true
  end
  
  def down
    # This is a destructive migration, so rollback will recreate the original structure
    # but data will be lost
    
    remove_index :dance_levels, :name if index_exists?(:dance_levels, :name)
    remove_index :dance_levels, :level_number if index_exists?(:dance_levels, :level_number)
    
    add_column :dance_levels, :dance_style_id, :bigint
    add_foreign_key :dance_levels, :dance_styles
    
    # You would need to manually recreate the dance level data for each style
    say "WARNING: This rollback will require manual recreation of dance level data for each style"
  end
end
