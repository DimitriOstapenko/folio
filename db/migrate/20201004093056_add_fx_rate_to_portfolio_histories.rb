class AddFxRateToPortfolioHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolio_histories, :fx_rate, :float, default: 1.0
  end
end
