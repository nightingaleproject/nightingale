class CreateStepRolePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :step_role_permissions do |t|
      t.timestamps
    end
    
    add_reference :step_role_permissions, :role, foreign_key: {to_table: :roles}
    add_reference :step_role_permissions, :step, foreign_key: {to_table: :steps}
  end
end
