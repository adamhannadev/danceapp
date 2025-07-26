class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :name
      t.string :event_type
      t.references :location, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.date :registration_deadline
      t.decimal :price
      t.integer :max_participants
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end
