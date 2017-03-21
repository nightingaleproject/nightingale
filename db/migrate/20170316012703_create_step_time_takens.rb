class CreateStepTimeTakens < ActiveRecord::Migration[5.0]
  def change
    create_table :step_time_takens do |t|
      t.float :time_taken
      t.string :step
      t.integer :user_id

      t.timestamps
    end
  end
end
