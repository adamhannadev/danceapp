class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.string :name
      t.text :address
      t.string :phone
      t.integer :capacity
      t.text :operating_hours
      t.boolean :active

      t.timestamps
    end
  end
end
