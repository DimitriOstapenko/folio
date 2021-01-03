class AddPosTypeToPosition < ActiveRecord::Migration[6.1]
  def change
    add_column :positions, :pos_type, :integer
  end
end
