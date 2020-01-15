class AddMessageIdToDeathRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :death_records, :message_id, :string
  end
end
