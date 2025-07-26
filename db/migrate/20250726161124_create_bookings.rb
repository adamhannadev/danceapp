class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :class_schedule, null: false, foreign_key: true
      t.string :booking_type
      t.string :status
      t.datetime :booked_at
      t.datetime :cancelled_at
      t.string :payment_status

      t.timestamps
    end
  end
end
