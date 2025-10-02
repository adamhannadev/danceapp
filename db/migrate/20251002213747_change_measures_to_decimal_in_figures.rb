class ChangeMeasuresToDecimalInFigures < ActiveRecord::Migration[7.2]
  def change
    change_column :figures, :measures, :decimal, precision: 5, scale: 2
  end
end
