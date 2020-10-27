class AddAvgPriceToPosition < ActiveRecord::Migration[5.2]
  def change
    add_column :positions, :avg_price, :float
  end
end
