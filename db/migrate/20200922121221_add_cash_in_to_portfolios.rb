class AddCashInToPortfolios < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolios, :cash_in, :float
    remove_column :portfolios, :acb, :float 
  end
end
