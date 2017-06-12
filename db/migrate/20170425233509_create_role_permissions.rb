class CreateRolePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :role_permissions do |t|
      t.string :role
      t.boolean :can_start_record
      t.boolean :can_register_record
      t.boolean :can_request_edits

      t.timestamps
    end
  end
end
