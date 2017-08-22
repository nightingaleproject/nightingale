module FormatPDF
    # Generates a list of objects that contain a string, and display 
    # information to be used when overlaying onto the PDF
    def self.format_data_for_pdf(death_record_data)
      formatted_data = []
      # Box 1 - Name
      decedent_name = death_record_data['decedentName.firstName']
      decedent_name = decedent_name + ', ' + death_record_data['decedentName.middleName'] if death_record_data['decedentName.middleName']
      decedent_name = decedent_name + ', ' + death_record_data['decedentName.lastName'] if death_record_data['decedentName.lastName']
      formatted_data.push({name: decedent_name, size:8, x:30, y:930})
        
      # Box 2 - Sex
      formatted_data.push({name: death_record_data['sex.sex'], size:8, x:315, y:930})

      # Box 3 - SSN
      formatted_data.push({name: death_record_data['ssn.ssn1'] + '-' + death_record_data['ssn.ssn2'] + '-' + death_record_data['ssn.ssn3'], size:8, x:350, y:930})

      # Box 4 - Age of Decedent
      death_date = Time.parse(death_record_data['dateOfDeath.dateOfDeath']) 
      birth_date = Time.parse(death_record_data['dateOfBirth.dateOfBirth'])
      years_old = death_date.year - birth_date.year
      # Box 4a - Years
      formatted_data.push({name: years_old.to_s, size:8, x:35, y:905})
      if years_old < 1
        months_old = death_date.month - birth_date.month
        days_old = death_date.day - birth_date.day
        # Box 4b - Months and Days
        formatted_data.push({name: months_old.to_s, size:8, x:110, y:903})
        formatted_data.push({name: days_old.to_s, size:8, x:145, y:903})
        
        if days_old < 1
          # TODO  We can't support less than a day old
          # Box 4c - Hours and Minutes
          formatted_data.push({name: 'Hours', size:8, x:175, y:903})
          formatted_data.push({name: 'Minutes', size:8, x:200, y:903})
        end
      end
      
      # Box 5 - Date of Birth
      birthdate = Time.parse(death_record_data['dateOfBirth.dateOfBirth']).strftime("%m/%d/%Y") if death_record_data['dateOfBirth.dateOfBirth']
      formatted_data.push({name: birthdate, size:8, x:250, y:905})
        
      # Box 6 - Place of Birth
      # If country is United States, include City and State, otherwise just include country
      birthplace = ''
      if death_record_data['placeOfBirth.country'] == 'United States'
        birthplace = death_record_data['placeOfBirth.city'] + ', ' + death_record_data['placeOfBirth.state'] if death_record_data['placeOfBirth.city'] && death_record_data['placeOfBirth.state']
      else 
        birthplace = death_record_data['placeOfBirth.country'] if death_record_data['placeOfBirth.country']
      end
      formatted_data.push({name: birthplace, size:8, x:330, y:905})

      # Box 7a - Residence State
      formatted_data.push({name: death_record_data['decedentAddress.state'], size:8, x:30, y:883})
      # Box 7b - Residence County
      formatted_data.push({name: death_record_data['decedentAddress.county'], size:8, x:170, y:883})
      # Box 7c - Residence City
      formatted_data.push({name: death_record_data['decedentAddress.city'], size:8, x:300, y:883})
      # Box 7d - Residence Street and Number
      formatted_data.push({name: death_record_data['decedentAddress.street'], size:8, x:30, y:868})
      # Box 7e - Residence Apartment Number
      formatted_data.push({name: death_record_data['decedentAddress.apt'], size:8, x:215, y:868})
      # Box 7f - Residence Zipcode
      formatted_data.push({name: death_record_data['decedentAddress.zip'], size:8, x:265, y:868})
      
      # Box 8 - Armed Forces Service
      if death_record_data['armedForcesService.armedForcesService'] == 'Yes'
        formatted_data.push({name: 'x', size:12, x:34, y:855})
      else
        formatted_data.push({name: 'x', size:12, x:58, y:855})
      end

      # Box 9 - Marital Status
      if death_record_data['maritalStatus.maritalStatus'] == 'Married'
         formatted_data.push({name: 'x', size:12, x:131, y:855})
      elsif death_record_data['maritalStatus.maritalStatus'] == 'Married, but separated'
         formatted_data.push({name: 'x', size:12, x:166, y:855})
      elsif death_record_data['maritalStatus.maritalStatus'] == 'Widowed'
         formatted_data.push({name: 'x', size:12, x:239, y:855})
      elsif death_record_data['maritalStatus.maritalStatus'] == 'Divorced'
         formatted_data.push({name: 'x', size:12, x:131, y:846})
      elsif death_record_data['maritalStatus.maritalStatus'] == 'Never married'
         formatted_data.push({name: 'x', size:12, x:166, y:846})
      elsif death_record_data['maritalStatus.maritalStatus'] == 'Unknown'
         formatted_data.push({name:'x', size:12, x:216, y:846})
      end

      # Box 10 - Spouse Name
      spouse_name = ''
      spouse_name = death_record_data['spouseName.firstName'] if death_record_data['spouseName.firstName']
      spouse_name = spouse_name + ', ' + death_record_data['spouseName.middleName'] if death_record_data['spouseName.middleName']
      spouse_name = spouse_name + ', ' + death_record_data['spouseName.lastName'] if death_record_data['spouseName.lastName']
      formatted_data.push({name: spouse_name, size:8, x:300, y:846})

      # Box 11 - Father's Name 
      father_name = ''
      father_name = death_record_data['fatherName.firstName'] if death_record_data['fatherName.firstName']
      father_name = father_name + ', ' + death_record_data['fatherName.middleName'] if death_record_data['fatherName.middleName']
      father_name = father_name + ', ' + death_record_data['fatherName.lastName'] if death_record_data['fatherName.lastName']
      formatted_data.push({name: father_name, size:8, x:30, y:823})

      # Box 12 - Mother's Name 
      mother_name = ''
      mother_name = death_record_data['motherName.firstName'] if death_record_data['motherName.firstName']
      mother_name = mother_name + ', ' + death_record_data['motherName.middleName'] if death_record_data['motherName.middleName']
      mother_name = mother_name + ', ' + death_record_data['motherName.lastName'] if death_record_data['motherName.lastName']
      formatted_data.push({name: mother_name, size:8, x:310, y:823})

      formatted_data
    end

    # Uses the list of objects to generate a pdf
    def self.generate_formatted_pdf(death_record_data)
        pdf = Prawn::Document.new
        pdf.render_file "death_certificate.pdf"
        pdf_data = FormatPDF.format_data_for_pdf(death_record_data)
        pdf_data.each do |element|
          pdf.text_box(element[:name],
               :size  => element[:size],
               :width => 250,
               :heigh => 5,
               :at    => [element[:x], element[:y]],
               :style  => :bold)
        end
        pdf.render
    end
end

#     # BOX 7g. Inside city limits
#     # Yes version
#     pdf.text_box("x",
#           :size   => 12,
#           :width  => 250,
#           :heigh  => 5,
#           :at     => [471, 875],
#           :style  => :bold)
