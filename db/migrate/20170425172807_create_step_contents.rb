class CreateStepContents < ActiveRecord::Migration[5.0]
  def change
    create_table :step_contents do |t|
      t.belongs_to :step
      t.belongs_to :death_record
      t.belongs_to :editor, class_name: 'User'
      t.json :contents, default: {}

      t.timestamps
    end
  end
end
