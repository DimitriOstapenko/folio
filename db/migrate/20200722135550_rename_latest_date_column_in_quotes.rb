class RenameLatestDateColumnInQuotes < ActiveRecord::Migration[5.2]
  def change
    rename_column :quotes, :latest_date, :latest_update
    change_column :quotes, :latest_update, :datetime
  end
end
