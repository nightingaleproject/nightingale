class CreateFuneralFacilities < ActiveRecord::Migration[5.0]
  def change
    create_table :funeral_facilities do |t|
      t.string :name
      t.string :street_and_number
      t.string :city
      t.string :county
      t.string :state
      t.string :zip_code

      t.timestamps
    end
  end
end
