class AddUserRefToPortfolios < ActiveRecord::Migration[5.2]
  def change
    add_reference :portfolios, :user, foreign_key: true
  end
end
