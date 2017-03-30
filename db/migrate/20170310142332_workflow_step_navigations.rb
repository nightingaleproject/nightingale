class WorkflowStepNavigations < ActiveRecord::Migration[5.0]
  def change
    create_table :workflow_step_navigations do |t|
      t.belongs_to :workflow, index: true, foreign_key: true
      t.integer :transition_order
      t.timestamps
    end
    
    add_reference :workflow_step_navigations, :current_step, foreign_key: {to_table: :steps}
    add_reference :workflow_step_navigations, :next_step, foreign_key: {to_table: :steps}
  end
end
