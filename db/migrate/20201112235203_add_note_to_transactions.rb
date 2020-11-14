class AddNoteToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :note, :string
  end
end
