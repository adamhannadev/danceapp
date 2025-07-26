class CreateDanceStyles < ActiveRecord::Migration[7.2]
  def change
    create_table :dance_styles do |t|
      t.string :name
      t.string :category
      t.text :description

      t.timestamps
    end
  end
end
