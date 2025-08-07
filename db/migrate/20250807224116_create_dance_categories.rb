class CreateDanceCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :dance_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
