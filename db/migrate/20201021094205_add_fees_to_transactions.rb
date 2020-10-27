class AddFeesToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :fees, :float, default: 0.0
  end
end
