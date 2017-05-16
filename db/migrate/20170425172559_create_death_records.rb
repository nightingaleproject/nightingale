class CreateDeathRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :death_records do |t|
      t.belongs_to :workflow, class_name: 'Workflow'
      t.belongs_to :owner, class_name: 'User'
      t.belongs_to :creator, class_name: 'User'
      t.belongs_to :step_flow
      t.json :contents, default: {}
      t.json :cached_json

      t.timestamps
    end
  end
end
