class AddDripToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :drip, :boolean, default: false
  end
end
