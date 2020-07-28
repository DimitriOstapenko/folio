class AddExchToQuotes < ActiveRecord::Migration[5.2]
  def change
    add_column :quotes, :exch, :string
  end
end
