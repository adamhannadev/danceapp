class AddDescriptionToDanceCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :dance_categories, :description, :text
  end
end
