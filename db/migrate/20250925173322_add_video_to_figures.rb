class AddVideoToFigures < ActiveRecord::Migration[7.2]
  def change
    add_column :figures, :video, :string
  end
end
