class CreateEventRegistrations < ActiveRecord::Migration[7.2]
  def change
    create_table :event_registrations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.datetime :registration_date
      t.string :payment_status
      t.text :notes

      t.timestamps
    end
  end
end
