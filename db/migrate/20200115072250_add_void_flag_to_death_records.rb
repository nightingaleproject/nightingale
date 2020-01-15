class AddVoidFlagToDeathRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :death_records, :voided, :boolean
  end
end
