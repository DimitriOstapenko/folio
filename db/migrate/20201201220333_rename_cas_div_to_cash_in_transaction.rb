class RenameCasDivToCashInTransaction < ActiveRecord::Migration[5.2]
  def change
    rename_column :transactions, :cashdiv, :cash
  end
end
