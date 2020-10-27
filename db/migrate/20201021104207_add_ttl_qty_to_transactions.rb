class AddTtlQtyToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :ttl_qty, :float, default:0.0
  end
end
