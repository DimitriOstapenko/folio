class AddUserToPortfolioHistories < ActiveRecord::Migration[5.2]
  def change
    add_reference :portfolio_histories, :user, foreign_key: true
  end
end
