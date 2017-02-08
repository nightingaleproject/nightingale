class CreateUserTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :user_tokens do |t|

      ## Guest Token
      t.string :token
      t.datetime :token_generated_at
      t.boolean :is_expired, default: false
      t.timestamps

    end

    add_reference :user_tokens, :user, index: true
    add_foreign_key :user_tokens, :users

    add_reference :user_tokens, :death_record, index: true
    add_foreign_key :user_tokens, :death_records
  end
end
