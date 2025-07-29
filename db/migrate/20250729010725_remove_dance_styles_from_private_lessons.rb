class RemoveDanceStylesFromPrivateLessons < ActiveRecord::Migration[7.2]
def change
  remove_column :private_lessons, :dance_style_id, :bigint
  remove_column :private_lessons, :dance_level_id, :bigint
end
end
