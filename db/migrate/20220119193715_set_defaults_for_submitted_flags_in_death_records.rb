class SetDefaultsForSubmittedFlagsInDeathRecords < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up do
        DeathRecord.where(initially_submitted: nil).update_all(initially_submitted: false)
        DeathRecord.where(currently_submitted: nil).update_all(currently_submitted: false)
        change_column :death_records, :initially_submitted, :boolean, null: false, default: false
        change_column :death_records, :currently_submitted, :boolean, null: false, default: false
      end
      direction.down do
        change_column :death_records, :initially_submitted, :boolean, null: true, default: nil
        change_column :death_records, :currently_submitted, :boolean, null: true, default: nil
      end
    end
  end
end
