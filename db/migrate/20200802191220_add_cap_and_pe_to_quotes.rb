class AddCapAndPeToQuotes < ActiveRecord::Migration[5.2]
  def change
    add_column :quotes, :market_cap, :float
    add_column :quotes, :pe_ratio, :float
  end
end
