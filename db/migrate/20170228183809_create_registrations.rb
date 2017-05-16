class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.belongs_to :death_record
      t.datetime :registered

      t.timestamps
    end
  end
end
