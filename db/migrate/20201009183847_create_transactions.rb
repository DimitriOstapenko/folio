class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.float :qty
      t.references :position, foreign_key: true

      t.timestamps
    end
  end
end
