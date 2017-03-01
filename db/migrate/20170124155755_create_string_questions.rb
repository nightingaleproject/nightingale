class CreateStringQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :string_questions do |t|

      t.timestamps
    end
  end
end
