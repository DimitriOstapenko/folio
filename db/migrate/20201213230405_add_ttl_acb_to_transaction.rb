class AddTtlAcbToTransaction < ActiveRecord::Migration[5.2]
  def change
#    remove_column :transactions, :ttl_acb, :string
#    remove_column :transactions, :float, :string
    add_column :transactions, :ttl_acb, :float
  end
end
