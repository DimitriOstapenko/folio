class CreateQuotes < ActiveRecord::Migration[5.2]
  def change
    create_table :quotes do |t|
      t.string :symbol
      t.string :exchange
      t.string :name
      t.float :latest_price
      t.float :prev_close
      t.float :volume
      t.float :prev_volume
      t.date :latest_date
      t.float :week52high
      t.float :week52low

      t.timestamps
    end
  end
end
