class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.timestamps
      t.string :message_id
      t.index :message_id
      t.text :json
    end
  end
end
