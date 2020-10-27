class AddAcbAndGainToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :acb, :float
    add_column :transactions, :gain, :float, default: 0.0
  end
end
