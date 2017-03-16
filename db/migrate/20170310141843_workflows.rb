class Workflows < ActiveRecord::Migration[5.0]
  def change
    create_table :workflows do |t|
      t.string :name

      t.timestamps
    end
  end
end
