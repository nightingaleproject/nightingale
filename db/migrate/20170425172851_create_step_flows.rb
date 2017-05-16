class CreateStepFlows < ActiveRecord::Migration[5.0]
  def change
    create_table :step_flows do |t|
      t.belongs_to :workflow
      t.string :current_step_role
      t.string :send_to_role, default: nil
      t.belongs_to :current_step, class_name: 'Step'
      t.belongs_to :next_step, class_name: 'Step'
      t.belongs_to :previous_step, class_name: 'Step'
      t.integer :transition_order

      t.timestamps
    end
  end
end
