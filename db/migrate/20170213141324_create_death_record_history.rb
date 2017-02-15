class CreateDeathRecordHistory < ActiveRecord::Migration[5.0]
  def change
    create_table :death_record_histories do |t|
      t.integer :death_record_id
      t.integer :user_id

      t.timestamps
    end
  end
end
