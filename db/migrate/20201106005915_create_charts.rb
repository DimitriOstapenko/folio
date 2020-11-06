class CreateCharts < ActiveRecord::Migration[5.2]
  def change
    create_table :charts do |t|
      t.string :symbol
      t.string :exch
      t.date :date
      t.float :price
      t.integer :volume

      t.timestamps
    end
  end
end
