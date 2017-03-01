class CreateAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :answers do |t|
      t.string :type
      t.text :answer
      t.integer :death_record_id
      t.integer :question_id
      t.text :question

      t.timestamps
    end
  end
end
