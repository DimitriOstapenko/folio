class RemoveCashFromPortfolios < ActiveRecord::Migration[5.2]
  def change
    remove_column :portfolios, :cash, :float
  end
end
