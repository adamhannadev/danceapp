class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :role
      t.string :membership_type
      t.decimal :membership_discount
      t.boolean :waiver_signed
      t.datetime :waiver_signed_at

      t.timestamps
    end
  end
end
