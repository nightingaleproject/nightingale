module FormatPdf
    # Generates a list of objects that contain a string, and display
    # information to be used when overlaying onto the PDF
    def self.format_data_for_pdf(death_record_data)
      formatted_data = []
      # Box 1 - Name
      decedent_name = death_record_data['decedentName.firstName']
      decedent_name = decedent_name + ', ' + death_record_data['decedentName.middleName'] if death_record_data['decedentName.middleName']
      decedent_name = decedent_name + ', ' + death_record_data['decedentName.lastName'] if death_record_data['decedentName.lastName']
      formatted_data.push({name: decedent_name, size:8, x:30, y:930}) if decedent_name

      # Box 2 - Sex
      formatted_data.push({name: death_record_data['sex.sex'], size:8, x:315, y:930}) if death_record_data['sex.sex']

      # Box 3 - SSN
      if death_record_data['ssn.ssn1'] && death_record_data['ssn.ssn2'] && death_record_data['ssn.ssn3']
        formatted_data.push({name: death_record_data['ssn.ssn1'] + '-' + death_record_data['ssn.ssn2'] + '-' + death_record_data['ssn.ssn3'], size:8, x:350, y:930})
      end

      # Box 4 - Age of Decedent
      death_date = Time.parse(death_record_data['dateOfDeath.dateOfDeath']) if death_record_data['dateOfDeath.dateOfDeath']
      birth_date = Time.parse(death_record_data['dateOfBirth.dateOfBirth']) if death_record_data['dateOfBirth.dateOfBirth']
      if death_date && birth_date
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
            # TODO  Don't support less than a day old
            # Box 4c - Hours and Minutes
            formatted_data.push({name: 'Hours', size:8, x:175, y:903})
            formatted_data.push({name: 'Minutes', size:8, x:200, y:903})
          end
        end
      end

      # Box 5 - Date of Birth
      birthdate = Time.parse(death_record_data['dateOfBirth.dateOfBirth']).strftime("%m/%d/%Y") if death_record_data['dateOfBirth.dateOfBirth']
      formatted_data.push({name: birthdate, size:8, x:250, y:905}) if birthdate

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
      formatted_data.push({name: death_record_data['decedentAddress.state'], size:8, x:30, y:883}) if death_record_data['decedentAddress.state']
      # Box 7b - Residence County
      formatted_data.push({name: death_record_data['decedentAddress.county'], size:8, x:170, y:883}) if death_record_data['decedentAddress.county']
      # Box 7c - Residence City
      formatted_data.push({name: death_record_data['decedentAddress.city'], size:8, x:300, y:883}) if death_record_data['decedentAddress.city']
      # Box 7d - Residence Street and Number
      formatted_data.push({name: death_record_data['decedentAddress.street'], size:8, x:30, y:868}) if death_record_data['decedentAddress.street']
      # Box 7e - Residence Apartment Number
      formatted_data.push({name: death_record_data['decedentAddress.apt'], size:8, x:215, y:868}) if death_record_data['decedentAddress.apt']
      # Box 7f - Residence Zipcode
      formatted_data.push({name: death_record_data['decedentAddress.zip'], size:8, x:265, y:868}) if death_record_data['decedentAddress.zip']

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
      spouse_name = death_record_data['spouseName.firstName'] if death_record_data['spouseName.firstName'] && !death_record_data['spouseName.firstName'].empty?
      spouse_name = spouse_name + ', ' + death_record_data['spouseName.middleName'] if death_record_data['spouseName.middleName'] && !death_record_data['spouseName.middleName'].empty?
      spouse_name = spouse_name + ', ' + death_record_data['spouseName.lastName'] if death_record_data['spouseName.lastName'] && !death_record_data['spouseName.lastName'].empty?
      formatted_data.push({name: spouse_name, size:8, x:300, y:846})

      # Box 11 - Father's Name
      father_name = ''
      father_name = death_record_data['fatherName.firstName'] if death_record_data['fatherName.firstName'] && !death_record_data['fatherName.firstName'].empty?
      father_name = father_name + ', ' + death_record_data['fatherName.middleName'] if death_record_data['fatherName.middleName'] && !death_record_data['fatherName.middleName'].empty?
      father_name = father_name + ', ' + death_record_data['fatherName.lastName'] if death_record_data['fatherName.lastName'] && !death_record_data['fatherName.lastName'].empty?
      formatted_data.push({name: father_name, size:8, x:30, y:823})

      # Box 12 - Mother's Name
      mother_name = ''
      mother_name = death_record_data['motherName.firstName'] if death_record_data['motherName.firstName'] && !death_record_data['motherName.firstName'].empty?
      mother_name = mother_name + ', ' + death_record_data['motherName.middleName'] if death_record_data['motherName.middleName'] && !death_record_data['motherName.middleName'].empty?
      mother_name = mother_name + ', ' + death_record_data['motherName.lastName'] if death_record_data['motherName.lastName'] && !death_record_data['motherName.lastName'].empty?
      formatted_data.push({name: mother_name, size:8, x:310, y:823})

      # Box 13a - Informant's Name
      informant_name = ''
      informant_name = death_record_data['informantName.firstName'] if death_record_data['informantName.firstName'] && !death_record_data['informantName.firstName'].empty?
      informant_name = informant_name + ', ' + death_record_data['informantName.middleName'] if death_record_data['informantName.middleName'] && !death_record_data['informantName.middleName'].empty?
      informant_name = informant_name + ', ' + death_record_data['informantName.lastName'] if death_record_data['informantName.lastName'] && !death_record_data['informantName.lastName'].empty?
      formatted_data.push({name: informant_name, size:8, x:30, y:798})

      # Box 13b - Relationship to Decedent
      # TODO: We do not support this field

      # Box 13C - Informant Mailing Address (Street and Number, City, State, Zip code)
      informant_address = ''
      informant_address = death_record_data['informantAddress.street'] if death_record_data['informantAddress.street'] && !death_record_data['informantAddress.street'].empty?
      informant_address = informant_address + ', ' + death_record_data['informantAddress.city'] if death_record_data['informantAddress.city'] && !death_record_data['informantAddress.city'].empty?
      informant_address = informant_address + ', ' + death_record_data['informantAddress.state'] if death_record_data['informantAddress.state'] && !death_record_data['informantAddress.state'].empty?
      informant_address = informant_address + ', ' + death_record_data['informantAddress.zip'] if death_record_data['informantAddress.zip'] && !death_record_data['informantAddress.zip'].empty?
      formatted_data.push({name: informant_address, size:8, x:305, y:798})

      # Box 14 - Place of Death (Check only one)
      if death_record_data['placeOfDeath.placeOfDeath.option'] == "Inpatient"
        formatted_data.push({name: 'x', size:11, x:31, y:772})
      elsif death_record_data['placeOfDeath.placeOfDeath.option'] == 'Outpatient/ER'
        formatted_data.push({name: 'x', size:11, x:63, y:772})
      elsif death_record_data['placeOfDeath.placeOfDeath.option'] == 'DOA'
        formatted_data.push({name: 'x', size:11, x:152, y:772})
      elsif death_record_data['placeOfDeath.placeOfDeath.option'] == 'Hospice Facility'
        formatted_data.push({name: 'x', size:11, x:222, y:772})
      elsif death_record_data['placeOfDeath.placeOfDeath.option'] == "Nursing Home/Long Term Care Facility"
        formatted_data.push({name: 'x', size:11, x:272, y:772})
      elsif death_record_data['placeOfDeath.placeOfDeath.option'] == "Decedent's Home"
        formatted_data.push({name: 'x', size:11, x:381, y:772})
      elsif death_record_data['placeOfDeath.placeOfDeath.option'] == "Other (specify)"
        formatted_data.push({name: 'x', size:11, x:440, y:772})
        other = death_record_data['placeOfDeath.placeOfDeath.specify'][0]
        if other && !other.empty?
          formatted_data.push({name: other, size:8, x:489, y:770})
        end
      end

      # Box 15 - Facility Name (if not institution, give street & number)
      facility_name = ''
      if death_record_data['locationOfDeath.name'] && !death_record_data['locationOfDeath.name'].empty?
        facility_name = death_record_data['locationOfDeath.name']
      elsif death_record_data['locationOfDeath.street'] && !death_record_data['locationOfDeath.street'].empty?
        facility_name = death_record_data['locationOfDeath.street']
        facility_name = facility_name + ', ' + death_record_data['locationOfDeath.apt'] if death_record_data['locationOfDeath.apt'] && !death_record_data['locationOfDeath.apt'].empty?
      end
      formatted_data.push({name: facility_name, size:8, x:31, y:750})

      # Box 16 - Location of Death (City or Town, State, and Zip)
      location_of_death = ''
      location_of_death = death_record_data['locationOfDeath.city'] if death_record_data['locationOfDeath.city'] && !death_record_data['locationOfDeath.city'].empty?
      location_of_death = location_of_death + ', ' + death_record_data['locationOfDeath.state'] if death_record_data['locationOfDeath.state'] && !death_record_data['locationOfDeath.state'].empty?
      location_of_death = location_of_death + ', ' + death_record_data['zip'] if death_record_data['zip'] && !death_record_data['zip'].empty?
      formatted_data.push({name: location_of_death, size:8, x:215, y:750})

      # Box 17 - County of Death
      county_of_death = ''
      county_of_death = death_record_data['locationOfDeath.county'] if death_record_data['locationOfDeath.county'] && !death_record_data['locationOfDeath.county'].empty?
      formatted_data.push({name: county_of_death, size:8, x:453, y:750})

      # Box 18 - Method of Disposition
      if death_record_data['methodOfDisposition.methodOfDisposition.option'] == 'Burial'
        formatted_data.push({name: 'x', size:11, x:124, y:742})
      elsif death_record_data['methodOfDisposition.methodOfDisposition.option'] == 'Cremation'
        formatted_data.push({name: 'x', size:11, x:151, y:742})
      elsif death_record_data['methodOfDisposition.methodOfDisposition.option'] == 'Donation'
        formatted_data.push({name: 'x', size:11, x:38, y:733})
      elsif death_record_data['methodOfDisposition.methodOfDisposition.option'] == 'Entombment'
        formatted_data.push({name: 'x', size:11, x:71, y:733})
      elsif death_record_data['methodOfDisposition.methodOfDisposition.option'] == 'Removal from State'
        formatted_data.push({name: 'x', size:11, x:115, y:733})
      elsif death_record_data['methodOfDisposition.methodOfDisposition.option'] == 'Other (specify)'
        formatted_data.push({name: 'x', size:11, x:38, y:724})
        other = death_record_data['methodOfDisposition.methodOfDisposition.specify']
        if other && !other.empty?
          formatted_data.push({name: other, size:8, x:88, y:722})
        end
      end

      # Box 19 - Place of Disposition (Name of cemetary, crematory, other place)
      formatted_data.push({name: death_record_data['placeOfDisposition.name'], size:8, x:207, y:722}) if death_record_data['placeOfDisposition.name']

      # Box 20 - Location-City Disposition, Town, And State
      location_of_disposition = death_record_data['placeOfDisposition.city'] if death_record_data['placeOfDisposition.city'] && !death_record_data['placeOfDisposition.city'].empty?
      location_of_disposition = location_of_disposition + ', ' + death_record_data['placeOfDisposition.state'] if death_record_data['placeOfDisposition.state'] && !death_record_data['placeOfDisposition.state'].empty?
      formatted_data.push({name: location_of_disposition, size:8, x:30, y:703}) if location_of_disposition

      # Box 21 - Name and Complete Address of Funeral Facility
      funeral_facility = death_record_data['funeralFacility.name'] if death_record_data['funeralFacility.name'] && !death_record_data['funeralFacility.name'].empty?
      funeral_facility = funeral_facility + ', ' + death_record_data['funeralFacility.street'] if death_record_data['funeralFacility.street'] && !death_record_data['funeralFacility.street'].empty?
      funeral_facility = funeral_facility + ', ' + death_record_data['funeralFacility.apt'] if death_record_data['funeralFacility.apt'] && !death_record_data['funeralFacility.apt'].empty?
      funeral_facility = funeral_facility + ', ' + death_record_data['funeralFacility.city'] if death_record_data['funeralFacility.city'] && !death_record_data['funeralFacility.city'].empty?
      funeral_facility = funeral_facility + ', ' + death_record_data['funeralFacility.state'] if death_record_data['funeralFacility.state'] && !death_record_data['funeralFacility.state'].empty?
      funeral_facility = funeral_facility + ', ' + death_record_data['funeralFacility.county'] if death_record_data['funeralFacility.county'] && !death_record_data['funeralFacility.county'].empty?
      funeral_facility = funeral_facility + ', ' + death_record_data['funeralFacility.zip'] if death_record_data['funeralFacility.zip'] && !death_record_data['funeralFacility.zip'].empty?
      formatted_data.push({name: funeral_facility, size:7, x:200, y:708}) if funeral_facility

      # Box 22 - Signature Of Funeral Service License or Other agent (TODO: Need to support this)

      # Box 23 - License Number
      formatted_data.push({name: death_record_data['funeralLicenseNumber.funeralLicenseNumber'], size:8, x:440, y: 680}) if death_record_data['funeralLicenseNumber.funeralLicenseNumber']

      # Box 24 - Date Pronounced Dead (Mo/Day/Yr)
      date_pronounced_dead = death_record_data['datePronouncedDead.datePronouncedDead'] if death_record_data['datePronouncedDead.datePronouncedDead'] && !death_record_data['datePronouncedDead.datePronouncedDead'].empty?
      if date_pronounced_dead
        temp_date = Date.strptime(date_pronounced_dead, "%Y-%m-%d")
        formatted_data.push({name: temp_date.strftime("%m/%d/%Y"), size: 8, x:245, y:660})
      end

      # Box 25 - Time Pronounced Dead
      formatted_data.push({name: death_record_data['timePronouncedDead.timePronouncedDead'], size:8, x:470, y:660}) if death_record_data['timePronouncedDead.timePronouncedDead']

      # Box 26 - Signature of Funeral Service Licensee (TODO: Need to support this)

      # Box 27 - License Number
      formatted_data.push({name: death_record_data['pronouncerLicenseNumber.pronouncerLicenseNumber'], size:8, x:300, y:640}) if death_record_data['pronouncerLicenseNumber.pronouncerLicenseNumber']

      # Box 28 - Date Signed (Mo/Day/Yr)
      date_signed = death_record_data['dateOfPronouncerSignature.dateOfPronouncerSignature'] if death_record_data['dateOfPronouncerSignature.dateOfPronouncerSignature'] && !death_record_data['dateOfPronouncerSignature.dateOfPronouncerSignature'].empty?
      if date_signed
        temp_date = Date.strptime(date_signed, "%Y-%m-%d")
        formatted_data.push({name: temp_date.strftime("%m/%d/%Y"), size:8, x:445, y:640})
      end

      # Box 29 - Actual or Presumed Date of Death
      date_of_death = death_record_data['dateOfDeath.dateOfDeath'] if death_record_data['dateOfDeath.dateOfDeath'] && !death_record_data['dateOfDeath.dateOfDeath'].empty?
      if date_of_death
        temp_date = Date.strptime(date_of_death, "%Y-%m-%d")
        formatted_data.push({name: temp_date.strftime("%m/%d/%Y"), size:8, x:115, y:620})
      end

      # Box 30 - Actual or Presumed Time of Death
      formatted_data.push({name: death_record_data['timeOfDeath.timeOfDeath'], size:8, x:218, y:617}) if death_record_data['timeOfDeath.timeOfDeath']

      # Box 31 - Was Medical Examiner Or Coroner Contacted
      if death_record_data['meOrCoronerContacted.meOrCoronerContacted'] == 'Yes'
        formatted_data.push({name: 'x', size:11, x:488, y:622})
      elsif death_record_data['meOrCoronerContacted.meOrCoronerContacted'] == 'No'
        formatted_data.push({name: 'x', size:11, x:507, y:622})
      end

      # Box 32 - Cause of Death
      # Immediate COD
      formatted_data.push({name: death_record_data['cod.immediate'], size:8, x:130, y:567}) if death_record_data['cod.immediate']
      # Immediate Onset
      formatted_data.push({name: death_record_data['cod.immediateInt'], size:8, x:505, y:567}) if death_record_data['cod.immediateInt']

      # Underlying causes
      formatted_data.push({name: death_record_data['cod.under1'], size:8, x:130, y:544}) if death_record_data['cod.under1']
      formatted_data.push({name: death_record_data['cod.under1Int'], size:8, x:505, y: 546}) if death_record_data['cod.under1Int']
      formatted_data.push({name: death_record_data['cod.under2'], size:8, x:130, y:523}) if death_record_data['cod.under2']
      formatted_data.push({name: death_record_data['cod.under2Int'], size:8, x:505, y:525}) if death_record_data['cod.under2Int']
      formatted_data.push({name: death_record_data['cod.under3'], size:8, x:130, y:504}) if death_record_data['cod.under3']
      formatted_data.push({name: death_record_data['cod.under3Int'], size:8, x:505, y:505}) if death_record_data['cod.under3Int']

      # Box 33 - Was Autopsy Performed
      if death_record_data['autopsyPerformed.autopsyPerformed'] == 'Yes'
        formatted_data.push({name: 'x', size:11, x:443, y:480})
      elsif death_record_data['autopsyPerformed.autopsyPerformed'] == 'No'
        formatted_data.push({name: 'x', size:11, x:467, y:480})
      end

      # Box 34 - Autopsy Findings Available
      if death_record_data['autopsyAvailableToCompleteCauseOfDeath.autopsyAvailableToCompleteCauseOfDeath'] == 'Yes'
        formatted_data.push({name: 'x', size:11, x:515, y:465})
      elsif death_record_data['autopsyAvailableToCompleteCauseOfDeath.autopsyAvailableToCompleteCauseOfDeath'] == 'No'
        formatted_data.push({name: 'x', size:11, x:535, y:465})
      end

      # Box 35 - Tobacco contribute to death
      if death_record_data['didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath'] == 'Yes'
        formatted_data.push({name: 'x', size:11, x:41, y:433})
      elsif death_record_data['didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath'] == 'No'
        formatted_data.push({name: 'x', size:11, x:62.5, y:433})
      elsif death_record_data['didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath'] == 'Probably'
        formatted_data.push({name: 'x', size:11, x:41, y:416})
      elsif death_record_data['didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath'] == 'Unknown'
        formatted_data.push({name: 'x', size:11, x:62.5, y:416})
      end

      # Box 36 - If Female (Pregnancy)
      if death_record_data['sex.sex'] == 'Female'
        if death_record_data['pregnancyStatus.pregnancyStatus'] == 'Not pregnant in the past year'
          formatted_data.push({name: 'x', size:11, x:157, y:448})
        elsif death_record_data['pregnancyStatus.pregnancyStatus'] == 'Pregnant at the time of death'
          formatted_data.push({name: 'x', size:11, x:157, y:433})
        elsif death_record_data['pregnancyStatus.pregnancyStatus'] == 'Not pregnant, but pregnant within 42 days of death'
          formatted_data.push({name: 'x', size:11, x:157, y:418})
        elsif death_record_data['pregnancyStatus.pregnancyStatus'] == 'Not pregnant, but pregnant 43 days to 1 year before death'
          formatted_data.push({name: 'x', size:11, x:157, y:403})
        elsif death_record_data['pregnancyStatus.pregnancyStatus'] == 'Unknown if pregnant within the past year'
          formatted_data.push({name: 'x', size:11, x:158, y:386})
        end
      end

      # Box 37 - Manner Of Death
      if death_record_data['mannerOfDeath.mannerOfDeath'] == 'Natural'
        formatted_data.push({name: 'x', size:11, x:354, y:442})
      elsif death_record_data['mannerOfDeath.mannerOfDeath'] == 'Accident'
        formatted_data.push({name: 'x', size:11, x:354, y:426})
      elsif death_record_data['mannerOfDeath.mannerOfDeath'] == 'Suicide'
        formatted_data.push({name: 'x', size:11, x:354, y:410})
      elsif death_record_data['mannerOfDeath.mannerOfDeath'] == 'Homicide'
        formatted_data.push({name: 'x', size:11, x:390, y:442})
      elsif death_record_data['mannerOfDeath.mannerOfDeath'] == 'Pending investigation'
        formatted_data.push({name: 'x', size:11, x:390, y:426})
      elsif death_record_data['mannerOfDeath.mannerOfDeath'] == 'Could not be determined'
        formatted_data.push({name: 'x', size:11, x:390, y:410})
      end

      # Box 38 - Date Of Injury (TODO: Not supported)
      # Box 39 - Time of Injury (TODO: Not supported)
      # Box 40 - Place of Injury (TODO: Not supported)
      # Box 41 - Injury at work? (TODO: Not supported)
      # Box 42 - Location of Injury (TODO: Not supported)
      # Box 43 - Describe How Injury Occurred (TODO: Not supported)
      # Box 44 - If Transportation Injury, Specify (TODO: Not supported)

      # Box 45 - Certifier  (Check only one)
      if death_record_data['certifierType.certifierType'] = 'Certifying Physician'
        formatted_data.push({name: 'x', size:11, x:36, y:278})
      elsif death_record_data['certifierType.certifierType'] = 'Pronouncing and Certifying Physician'
        formatted_data.push({name: 'x', size:11, x:36, y:270})
      elsif death_record_data['certifierType.certifierType'] = 'Medical Examiner/Coroner'
        formatted_data.push({name: 'x', size:11, x:35, y:261})
      end
      # TODO: Signature of certifier (Not implemented)

      # Box 46 - Name, Address, Zip Code of Person compleing COD.
      person_cod = ''
      person_cod_name = ''
      person_cod_name = death_record_data['personCompletingCauseOfDeathName.firstName'] if death_record_data['personCompletingCauseOfDeathName.firstName'] && !death_record_data['personCompletingCauseOfDeathName.firstName'].empty?
      person_cod_name = person_cod_name + ', ' +  death_record_data['personCompletingCauseOfDeathName.middleName'] if death_record_data['personCompletingCauseOfDeathName.middleName'] && !death_record_data['personCompletingCauseOfDeathName.middleName'].empty?
      person_cod_name = person_cod_name + ', ' + death_record_data['personCompletingCauseOfDeathName.lastName'] if death_record_data['personCompletingCauseOfDeathName.lastName'] && !death_record_data['personCompletingCauseOfDeathName.lastName'].empty?
      person_cod = person_cod_name
      person_cod_address = ''
      person_cod_address = death_record_data['personCompletingCauseOfDeathAddress.street'] if death_record_data['personCompletingCauseOfDeathAddress.street'] && !death_record_data['personCompletingCauseOfDeathAddress.street'].empty?
      person_cod_address = person_cod_address + ', ' + death_record_data['personCompletingCauseOfDeathAddress.apt'] if death_record_data['personCompletingCauseOfDeathName.apt'] && !death_record_data['personCompletingCauseOfDeathName.apt'].empty?
      person_cod_address = person_cod_address + ', ' + death_record_data['personCompletingCauseOfDeathAddress.city'] if death_record_data['personCompletingCauseOfDeathAddress.city'] && !death_record_data['personCompletingCauseOfDeathAddress.city'].empty?
      person_cod_address = person_cod_address + ', ' + death_record_data['personCompletingCauseOfDeathAddress.state'] if death_record_data['personCompletingCauseOfDeathAddress.state'] && !death_record_data['personCompletingCauseOfDeathAddress.city'].empty?
      person_cod_address = person_cod_address + ', ' + death_record_data['personCompletingCauseOfDeathAddress.zip'] if death_record_data['personCompletingCauseOfDeathAddress.zip'] && !death_record_data['personCompletingCauseOfDeathAddress.zip'].empty?
      person_cod = person_cod + '      ' + person_cod_address
      formatted_data.push({name: person_cod, size:8, x:35, y:220})

      # Box 47 Title of Certifier (TODO: Not Implemented)

      # Box 48 License Number
      formatted_data.push({name: death_record_data['personCompletingCauseOfDeathLicenseNumber.personCompletingCauseOfDeathLicenseNumber'], size:8, x:110, y:196}) if death_record_data['personCompletingCauseOfDeathLicenseNumber.personCompletingCauseOfDeathLicenseNumber']

      # Box 49 Date Certified
      date_certified = death_record_data['dateCertified.dateCertified'] if death_record_data['dateCertified.dateCertified'] && !death_record_data['dateCertified.dateCertified'].empty?
      if date_certified
        temp_date = Date.strptime(date_certified, "%Y-%m-%d")
        formatted_data.push({name: temp_date.strftime("%m/%d/%Y"), size:8, x:220, y:196})
      end

      # Box 50 - For Registrar ONly (Date Filed (Mo/Day/Yr))
      # TODO: Not Implemented

      # Box 51 - Decedent's Educaation
      if death_record_data['education.education'] == '8th grade or less'
        formatted_data.push({name: 'x', size:11, x:26, y:161})
      elsif death_record_data['education.education'] == '9th - 12th grade, no diploma'
        formatted_data.push({name: 'x', size:11, x:26, y:150})
      elsif death_record_data['education.education'] == 'High school graduate or GED completed'
        formatted_data.push({name: 'x', size:11, x:26, y:137})
      elsif death_record_data['education.education'] == 'Some college credit, but no degree'
        formatted_data.push({name: 'x', size:11, x:26, y:126})
      elsif death_record_data['education.education'] == "Associate's degree"
        formatted_data.push({name: 'x', size:11, x:26, y:116})
      elsif death_record_data['education.education'] == "Bachelor's degree"
        formatted_data.push({name: 'x', size:11, x:26, y:101})
      elsif death_record_data['education.education'] == "Master's degree"
        formatted_data.push({name: 'x', size:11, x:26, y:90})
      elsif death_record_data['education.education'] == 'Doctorate or Professional degree'
        formatted_data.push({name: 'x', size:11, x:26, y:73})
      end

      # Box 52 - Decedent Of Hispanic Origin
      if death_record_data['hispanicOrigin.hispanicOrigin.option'] == 'No'
        formatted_data.push({name: 'x', size:11, x:163, y:146})
      elsif death_record_data['hispanicOrigin.hispanicOrigin.option'] == 'Yes' && death_record_data['hispanicOrigin.hispanicOrigin.specify'].include?('Mexican')
        formatted_data.push({name: 'x', size:11, x:163, y:131})
      elsif death_record_data['hispanicOrigin.hispanicOrigin.option'] == 'Yes' && death_record_data['hispanicOrigin.hispanicOrigin.specify'].include?('Puerto Rican')
        formatted_data.push({name: 'x', size:11, x:163, y:118})
      elsif death_record_data['hispanicOrigin.hispanicOrigin.option'] == 'Yes' && death_record_data['hispanicOrigin.hispanicOrigin.specify'].include?('Cuban')
        formatted_data.push({name: 'x', size:11, x:163, y:103})
      elsif death_record_data['hispanicOrigin.hispanicOrigin.option'] == 'Yes, other'
        formatted_data.push({name: 'x', size:11, x:163, y:89})
        formatted_data.push({name: 'specify', size:8, x:203, y:80})
      end

      # Box 53 - Decedent's Race
      formatted_data.push({name: 'x', size:9, x:346, y:168}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('White')
      formatted_data.push({name: 'x', size:9, x:346, y:162}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('African American')
      formatted_data.push({name: 'x', size:9, x:346, y:156}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('American Indian')  # Will need a naother line for (tribe)
      formatted_data.push({name: 'x', size:9, x:346, y:144}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Asian Indian')
      formatted_data.push({name: 'x', size:9, x:346, y:138}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Chinese')
      formatted_data.push({name: 'x', size:9, x:346, y:132}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Filipino')
      formatted_data.push({name: 'x', size:9, x:346, y:126}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Japanese')
      formatted_data.push({name: 'x', size:9, x:346, y:120}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Korean')
      formatted_data.push({name: 'x', size:9, x:346, y:114}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Vietnamese')
      formatted_data.push({name: 'x', size:9, x:346, y:108}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Other Asian')  # Need another line for (specify)
      formatted_data.push({name: 'x', size:9, x:346, y:102}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Native Hawaiian')
      formatted_data.push({name: 'x', size:9, x:346, y:96}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Guamanian')
      formatted_data.push({name: 'x', size:9, x:346, y:90}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Samoan')
      formatted_data.push({name: 'x', size:9, x:346, y:84}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Other Pacific Islander') # Need another line
      formatted_data.push({name: 'x', size:9, x:346, y:76}) if death_record_data['race.race.specify'] && death_record_data['race.race.specify'].include?('Other (Specify)') # Need another line

      # Box 54 - Usual Occupation
      formatted_data.push({name: death_record_data['usualOccupation.usualOccupation'], size:8, x:30, y:38}) if death_record_data['usualOccupation.usualOccupation']

      # Box 55 - Kind of Business/Industry
      formatted_data.push({name: death_record_data['kindOfBusiness.kindOfBusiness'], size:8, x:30, y:23}) if death_record_data['kindOfBusiness.kindOfBusiness']

      formatted_data
    end

    # Uses the list of objects to generate a pdf
    def self.generate_formatted_pdf(death_record_data)
        pdf = Prawn::Document.new
        pdf.render_file "death_certificate.pdf"
        pdf_data = format_data_for_pdf(death_record_data)
        pdf_data.each do |element|
          pdf.text_box(element[:name],
               :size  => element[:size],
               :width => 350,
               :heigh => 5,
               :at    => [element[:x], element[:y]],
               :style  => :bold)
        end
        pdf.render
    end
end
