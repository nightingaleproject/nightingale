class CreateCauseOfDeaths < ActiveRecord::Migration[5.0]
  def change
    create_table :cause_of_deaths do |t|
      t.string :cause
      
      # Examples of this could be '3 days', 'Two weeks', '4 hours'
      t.string :interval_to_death
      
      # Used to order the causes of death only 
      t.integer :position

      # There are two kinds of "causes of death", each with the same fields. 
      #  An "immedidate" cause of death is the acute reason the decedent died
      #  One or more "underlying" causes of death is also provided to capture 
      #  any contributing conditions
      #
      #  The modeling for this at the moment simply assumes that the first cod 
      #  is the immediate cod, and each subsequent one is an underlying cod
      #
      # TODO:  Consider modeling this in a more complex way that consists of 
      #  a single immediate CauseOfDeath and a list that is the underlying ones. 
      #  For now I'm not sure that is required
      
      t.belongs_to :death_record, foreign_key: "death_record_id", index: true
    
      t.timestamps
    end
  end
end
