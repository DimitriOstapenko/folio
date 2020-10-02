class AddAvgFxToPositions < ActiveRecord::Migration[5.2]
  def change
    add_column :positions, :avg_fx_rate, :float, default:  1.0
  end
end
