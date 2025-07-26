class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :payment_method
      t.string :transaction_id
      t.string :status
      t.datetime :payment_date
      t.string :invoice_number
      t.text :description

      t.timestamps
    end
  end
end
