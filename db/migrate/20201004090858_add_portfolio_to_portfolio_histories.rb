class AddPortfolioToPortfolioHistories < ActiveRecord::Migration[5.2]
  def change
    add_reference :portfolio_histories, :portfolio, foreign_key: true
  end
end
