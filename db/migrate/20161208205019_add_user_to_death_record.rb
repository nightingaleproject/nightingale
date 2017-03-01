class AddUserToDeathRecord < ActiveRecord::Migration[5.0]
  def change
    add_reference :death_records, :owner, foreign_key: {to_table: :users}
  end
end
