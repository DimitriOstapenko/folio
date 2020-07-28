class AddColumnsToQuote < ActiveRecord::Migration[5.2]
  def change
    add_column :quotes, :ytd_change, :float
    add_column :quotes, :change, :float
    add_column :quotes, :change_percent, :float
    add_column :quotes, :change_percent_s, :string
  end
end
