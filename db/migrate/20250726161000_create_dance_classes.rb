class CreateDanceClasses < ActiveRecord::Migration[7.2]
  def change
    create_table :dance_classes do |t|
      t.string :name
      t.references :dance_style, null: false, foreign_key: true
      t.references :dance_level, null: false, foreign_key: true
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.references :location, null: false, foreign_key: true
      t.integer :duration_minutes
      t.integer :max_capacity
      t.decimal :price
      t.text :description
      t.string :class_type

      t.timestamps
    end
  end
end
