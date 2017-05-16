class CreateZipcodes < ActiveRecord::Migration[5.0]
  def change
    create_table :zipcodes do |t|
      t.belongs_to :state
      t.belongs_to :county
      t.belongs_to :city
      
      t.string :name

      t.timestamps
    end
  end
end
