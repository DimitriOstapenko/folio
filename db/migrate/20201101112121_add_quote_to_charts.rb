class AddQuoteToCharts < ActiveRecord::Migration[5.2]
  def change
    add_reference :charts, :quote, foreign_key: true
  end
end
