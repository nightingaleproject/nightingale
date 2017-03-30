class DeathRecordFlows < ActiveRecord::Migration[5.0]
  def change
    create_table :death_record_flows do |t|
      t.timestamps
    end

    add_reference :death_record_flows, :current_step, foreign_key: {to_table: :steps}
    add_reference :death_record_flows, :next_step, foreign_key: {to_table: :steps}
    add_reference :death_record_flows, :workflow, foreign_key: {to_table: :workflows}
    add_reference :death_record_flows, :death_record, foreign_key: {to_table: :death_records}
  end
end
