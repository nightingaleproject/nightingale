class CreateDecedents < ActiveRecord::Migration[5.0]
  def change
    create_table :decedents do |t|
      # relationship with other entities
      t.belongs_to :death_record
      
      # identity information - start
      
      t.string :first_name, :middle_name, :last_name
      t.string :suffixes  #is string field sufficient?
      t.string :akas  #is string field sufficient?
      t.string :social_security_number
      
      #decedent's residence
      t.string :street_number, :appt_number, :city, :state, :country, :zip_code
      t.boolean :inside_city_limits
      
      #TODO:  Consider some kind of "Identity" abstraction for things like spouse,
      # father, mother
      #decedent's spouse information
      t.string :spouse_first_name, :spouse_last_name, :spouse_middle_name, :spouse_suffixes
      
      #decedent's father information
      t.string :father_first_name, :father_last_name, :father_middle_name, :father_suffixes
      
      #decedent's mother information
      t.string :mother_first_name, :mother_last_name, :mother_middle_name, :mother_suffixes
      
      # identity information - end
      
      # demographics - start
      
      t.string :sex
      t.date :date_of_birth
     
      #birth place information
      t.string :birthplace_city, :birthplace_state, :birthplace_country
      
      t.boolean :ever_in_us_armed_forces
      
      #series of enumerated values.  For now storing as strings, but we need to consider a better solution.  
      # ActiveRecord has an enum type, but uses integers to store the value, which has drawbacks.  
      t.string :marital_status_at_time_of_death 
      t.string :education
      t.string :hispanic_origin
      t.string :race
      t.string :usual_occupation
      t.string :kind_of_business
      #demographics - end
      
      
      # created update timestamps
      t.timestamps
    end
  end
end
