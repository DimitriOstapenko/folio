class AddHighAndLowToQuotes < ActiveRecord::Migration[5.2]
  def change
    add_column :quotes, :high, :float
    add_column :quotes, :low, :float
  end
end
