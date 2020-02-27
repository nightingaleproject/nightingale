class AddCodesToDeathRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :death_records, :coding_message_id, :string
    # TODO: Fine for a POC, but a better approach is needed for real code handling
    add_column :death_records, :underlying_cause_code, :string
    add_column :death_records, :record_cause_codes, :string
    add_column :death_records, :entity_cause_codes, :string
  end
end
