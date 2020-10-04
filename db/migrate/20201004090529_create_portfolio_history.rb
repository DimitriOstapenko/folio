class CreatePortfolioHistory < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolio_histories do |t|
      t.float :acb
      t.float :cash
      t.float :curval
      
      t.timestamps
    end
  end
end
