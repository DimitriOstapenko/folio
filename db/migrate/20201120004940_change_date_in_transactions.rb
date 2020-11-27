class ChangeDateInTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :date, :datetime
  end
end
