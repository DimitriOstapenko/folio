class AddCashDivToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :cashdiv, :float
  end
end
