class CreateSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :steps do |t|
      t.string :name
      t.string :abbrv
      t.string :description
      t.string :version
      t.json :jsonschema
      t.json :uischema
      t.string :icon
      t.string :step_type

      t.timestamps
    end
  end
end
