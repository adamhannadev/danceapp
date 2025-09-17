class CreateRoutines < ActiveRecord::Migration[7.2]
  def change
    create_table :routines do |t|
      t.references :user, null: false, foreign_key: true
      t.references :dance_category, null: false, foreign_key: true
      t.references :dance_style, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
