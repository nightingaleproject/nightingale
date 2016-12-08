class AddUserToDeathRecord < ActiveRecord::Migration[5.0]
  def change
    add_reference :death_records, :user, foreign_key: true
  end
end
