class Steps < ActiveRecord::Migration[5.0]
  def change
    create_table :steps do |t|
      t.string :name

      t.timestamps
    end
  end
end
