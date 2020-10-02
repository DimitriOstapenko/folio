class RenameCashInInPortfolios < ActiveRecord::Migration[5.2]
  def change
    rename_column :portfolios, :cash_in, :cash
  end
end
