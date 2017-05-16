class CreateStepHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :step_histories do |t|
      t.belongs_to :step
      t.belongs_to :death_record
      t.belongs_to :user
      t.float :time_taken

      t.timestamps
    end
  end
end
