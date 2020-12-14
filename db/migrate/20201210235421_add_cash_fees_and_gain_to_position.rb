class AddCashFeesAndGainToPosition < ActiveRecord::Migration[5.2]
  def change
    add_column :positions, :cash, :float
    add_column :positions, :fees, :float
    add_column :positions, :gain, :float
  end
end
