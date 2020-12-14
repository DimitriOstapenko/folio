class AddTtlCashToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :ttl_cash, :float
  end
end
