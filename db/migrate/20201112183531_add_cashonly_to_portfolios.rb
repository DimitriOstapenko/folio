class AddCashonlyToPortfolios < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolios, :cashonly, :boolean, default: false
  end
end
