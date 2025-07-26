class CreateFigures < ActiveRecord::Migration[7.2]
  def change
    create_table :figures do |t|
      t.string :figure_number
      t.string :name
      t.references :dance_style, null: false, foreign_key: true
      t.references :dance_level, null: false, foreign_key: true
      t.integer :measures
      t.text :components
      t.boolean :is_core

      t.timestamps
    end
  end
end
