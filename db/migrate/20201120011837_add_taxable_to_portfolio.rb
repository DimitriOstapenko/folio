class AddTaxableToPortfolio < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolios, :taxable, :boolean, default: false
  end
end
