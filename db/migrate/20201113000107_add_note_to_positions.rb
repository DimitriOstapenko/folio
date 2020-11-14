class AddNoteToPositions < ActiveRecord::Migration[5.2]
  def change
    add_column :positions, :note, :string
  end
end
