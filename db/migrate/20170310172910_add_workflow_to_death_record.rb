class AddWorkflowToDeathRecord < ActiveRecord::Migration[5.0]
  def change
    add_reference :death_records, :death_record_flow, foreign_key: {to_table: :death_record_flows}
  end
end
