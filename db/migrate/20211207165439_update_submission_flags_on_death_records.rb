class UpdateSubmissionFlagsOnDeathRecords < ActiveRecord::Migration[5.0]
  def change
    rename_column :death_records, :submitted, :initially_submitted
    add_column :death_records, :currently_submitted, :boolean
  end
end
