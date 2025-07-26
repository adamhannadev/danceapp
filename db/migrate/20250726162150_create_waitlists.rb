class CreateWaitlists < ActiveRecord::Migration[7.2]
  def change
    create_table :waitlists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :class_schedule, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
