class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.belongs_to :state
      t.belongs_to :county
      
      t.string :name

      t.timestamps
    end
  end
end
