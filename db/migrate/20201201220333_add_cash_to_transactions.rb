class AddCashToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :cash, :float
  end
end
