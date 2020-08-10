class CreatePortfolios < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolios do |t|
      t.string :name
      t.string :currency
      t.float :acb

      t.timestamps
    end
  end
end
