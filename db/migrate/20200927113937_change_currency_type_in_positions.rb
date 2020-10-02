class ChangeCurrencyTypeInPositions < ActiveRecord::Migration[5.2]
  def change
    remove_column :positions, :currency, :string
    add_column :positions, :currency, :integer
  end
end
