class AddUniqueIndexToCharts < ActiveRecord::Migration[5.2]
  def change
    add_index :charts, [:symbol, :date], unique: true
  end
end
