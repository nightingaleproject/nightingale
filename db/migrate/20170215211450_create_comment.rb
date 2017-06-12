class CreateComment < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.belongs_to :death_record
      t.belongs_to :user
      t.string :content

      t.timestamps
    end
  end
end
