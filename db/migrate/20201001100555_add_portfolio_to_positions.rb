class AddPortfolioToPositions < ActiveRecord::Migration[5.2]
  def change
    add_reference :positions, :portfolio, foreign_key: true
  end
end
