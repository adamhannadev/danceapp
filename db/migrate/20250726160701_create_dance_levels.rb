class CreateDanceLevels < ActiveRecord::Migration[7.2]
  def change
    create_table :dance_levels do |t|
      t.string :name
      t.integer :level_number
      t.references :dance_style, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
