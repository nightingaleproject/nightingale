class CreateMultipleChoiceQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :multiple_choice_questions do |t|

      t.timestamps
    end
  end
end
