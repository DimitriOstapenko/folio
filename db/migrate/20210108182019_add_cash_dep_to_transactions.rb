class AddCashDepToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :cashdep, :boolean, default: false
  end
end
