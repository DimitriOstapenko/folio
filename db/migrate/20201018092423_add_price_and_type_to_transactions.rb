class AddPriceAndTypeToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :price, :float
    add_column :transactions, :tr_type, :integer
  end
end
