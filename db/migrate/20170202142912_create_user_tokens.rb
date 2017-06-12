class CreateUserTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :user_tokens do |t|
      t.belongs_to :death_record
      t.belongs_to :user
      t.string :token
      t.datetime :token_generated_at
      t.boolean :is_expired, default: false

      t.timestamps
    end
  end
end
