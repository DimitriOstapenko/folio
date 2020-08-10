class CreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.string :symbol
      t.string :exch
      t.float :avg_price
      t.float :qty
      t.string :currency

      t.timestamps
    end
  end
end
