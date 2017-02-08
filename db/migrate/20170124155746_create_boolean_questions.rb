class CreateBooleanQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :boolean_questions do |t|

      t.timestamps
    end
  end
end
