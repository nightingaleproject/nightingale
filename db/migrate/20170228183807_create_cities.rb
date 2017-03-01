class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.belongs_to :county, index: true
      t.belongs_to :state, index: true
      
      t.string :name

      t.timestamps
    end
  end
end
