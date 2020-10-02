class RemoveCategoryFromPostions < ActiveRecord::Migration[5.2]
  def change
    remove_column :positions, :category
  end
end
