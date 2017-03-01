class CreateCounties < ActiveRecord::Migration[5.0]
  def change
    create_table :counties do |t|
      t.belongs_to :state, index: true
      
      t.string :name

      t.timestamps
    end
  end
end
