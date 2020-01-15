class AddSubmittedFlagToDeathRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :death_records, :submitted, :boolean
  end
end
