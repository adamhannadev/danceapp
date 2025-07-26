class CreatePrivateLessons < ActiveRecord::Migration[7.2]
  def change
    create_table :private_lessons do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.references :dance_style, null: false, foreign_key: true
      t.references :dance_level, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.datetime :scheduled_at
      t.integer :duration_minutes
      t.decimal :price
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
