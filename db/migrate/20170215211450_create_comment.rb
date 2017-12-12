class CreateComment < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.belongs_to :death_record
      t.belongs_to :user
      t.string :content
      t.boolean :requested_edits, default: false

      t.timestamps
    end
  end
end
