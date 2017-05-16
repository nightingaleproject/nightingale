class CreateWorkflows < ActiveRecord::Migration[5.0]
  def change
    create_table :workflows do |t|
      t.string :name
      t.string :description
      t.string :initiator_role

      t.timestamps
    end
  end
end
