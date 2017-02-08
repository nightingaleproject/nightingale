class CreateDateTimeQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :date_time_questions do |t|

      t.timestamps
    end
  end
end
