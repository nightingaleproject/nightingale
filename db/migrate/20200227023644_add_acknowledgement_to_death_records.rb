class AddAcknowledgementToDeathRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :death_records, :acknowledgement_message_id, :string
  end
end
