class NewCreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.integer :category
      t.string :symbol
      t.float :qty
      t.string :exch
      t.integer :currency
      t.float :acb
      
      t.timestamps
    end
  end
end
