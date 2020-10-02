class ChangeCurrencyTypeInPortfolios < ActiveRecord::Migration[5.2]
  def change
    remove_column :portfolios, :currency, :string
    add_column :portfolios, :currency, :integer
  end
end
