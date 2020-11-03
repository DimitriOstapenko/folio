class CreateCharts < ActiveRecord::Migration[5.2]
  def change
    create_table :charts do |t|
      t.float :change
      t.float :change_over_time
      t.float :change_percent
      t.string :change_percent_s
      t.float :close
      t.date :date
      t.float :high
      t.string :label
      t.float :low
      t.float :open
      t.float :u_close
      t.float :u_high
      t.float :u_low
      t.float :u_open
      t.integer :u_volume
      t.integer :volume

      t.timestamps
    end
  end
end
