class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :type
      t.string :question_type
      t.text :question
      t.boolean :required
      t.string :step
      t.text :multi_options

      t.timestamps
    end
  end
end
