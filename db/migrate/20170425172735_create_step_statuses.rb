class CreateStepStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :step_statuses do |t|
      t.belongs_to :death_record
      t.belongs_to :current_step, class_name: 'Step'
      t.belongs_to :next_step, class_name: 'Step'
      t.belongs_to :previous_step, class_name: 'Step'
      t.belongs_to :requestor, class_name: 'User', default: nil

      t.timestamps
    end
  end
end
