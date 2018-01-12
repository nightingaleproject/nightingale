# Helper module for importing FHIR death records into Nightingale
module FhirConsumerHelper

  # Given a FHIR death record, build and return an equivalent Nightingle contents
  # structure (that can be used to create/update the information in a
  # Nightingale death record).
  def self.from_fhir(fhir_record)
    contents = {}

    # TODO: Find a better way to figure out what entry is what

    # Grab decedent and certifier
    contents.merge! FhirConsumerHelper.decedent(fhir_record.entry[1])
    contents.merge! FhirConsumerHelper.certifier(fhir_record.entry[2])

    # Grab potential conditions
    index = 3
    (3..6).each do |c|
      entry = fhir_record.entry[c]
      # Stop checking if we've exhausted the cause of deaths
      break unless entry.resource.text.present? && entry.resource.respond_to?('onsetString')
      index += 1
      contents.merge! FhirConsumerHelper.cause_of_death_condition(entry, c-3)
    end

    # Grab observations
    (index..fhir_record.entry.count-1).each do |o|
      entry = fhir_record.entry[o]
      case entry.resource.code.coding.first.code
      when '81956-5'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Actual-Or-Presumed-Date-Of-Death
        contents.merge! FhirConsumerHelper.actual_or_presumed_date_of_death(entry)
      when '85699-7'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Performed
        contents.merge! FhirConsumerHelper.autopsy_performed(entry)
      when '69436-4'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Results-Available
        contents.merge! FhirConsumerHelper.autopsy_results_available(entry)
      when '80616-6'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Date-Pronounced-Dead
        contents.merge! FhirConsumerHelper.date_pronounced_dead(entry)
      when '69444-8'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Death-Resulted-From-Injury-At-Work
        contents.merge! FhirConsumerHelper.death_resulted_from_injury_at_work(entry)
      when '69448-9'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Injury-Leading-To-Death-Associated-Trans
        contents.merge! FhirConsumerHelper.injury_leading_to_death_associated_trans(entry)
      when '69449-7'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Manner-Of-Death
        contents.merge! FhirConsumerHelper.manner_of_death(entry)
      when '74497-9'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Medical-Examiner-Or-Coroner-Contacted
        contents.merge! FhirConsumerHelper.medical_examiner_or_coroner_contacted(entry)
      when '69442-2'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Timing-Of-Pregnancy-In-Relation-To-Death
        contents.merge! FhirConsumerHelper.timing_of_pregnancy_in_relation_to_death(entry)
      when '69443-0'
        # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Tobacco-Use-Contributed-To-Death
        contents.merge! FhirConsumerHelper.tobacco_use_contributed_to_death(entry)
      end
    end

    contents
  end


  #############################################################################
  # The below section is for consuming the FHIR death record decedent
  # information that is included in a FHIR death record.
  #############################################################################

  # Returns decedent information in Nightingale form given a FHIR death record.
  def self.decedent(decedent_entry)
    patient = decedent_entry.resource
    decedent = {}

    # NOTE: All of this is pretty much optional; will need to be careful
    # about handling cases where these things are not in the FHIR record.

    # TODO: Should SSN be included here?

    # Handle name
    if patient.name && patient.name.length > 0
      name = patient.name.first
      decedent['decedentName.firstName'] = name.given.first if name.given && name.given.first.present?
      # All subsequent 'given' names will be combined and included as the 'middle name'
      decedent['decedentName.middleName'] = name.given.drop(1).join(' ') if name.given && name.given.drop(1).any? && !name.given.drop(1).join(' ').blank?
      # All 'family' names will be combined and included as the 'last name'
      if name.family.is_a?(Array)
        decedent['decedentName.lastName'] = name.family.join(' ') if name.family && name.family.any?
      else
        decedent['decedentName.lastName'] = name.family
      end 
      certifier['decedentName.suffix'] = name.suffix.join(' ') if name.suffix && name.suffix.any? && !name.suffix.join(' ').blank?
    end
    # Handle date of birth
    decedent['dateOfBirth.dateOfBirth'] = patient.birthDate if patient.birthDate.present?
    # Handle date and time of death
    if patient.deceasedDateTime.present?
      dateTime = DateTime.parse(patient.deceasedDateTime)
      decedent['dateOfDeath.dateOfDeath'] = dateTime.strftime('%F')
      decedent['timeOfDeath.timeOfDeath'] = dateTime.strftime('%H:%M')
    end
    # Handle address
    if patient.address.present?
      address = patient.address.first
      decedent['decedentAddress.street'] = address.line.first if address.line && address.line.first.present?
      decedent['decedentAddress.city'] = address.city.strip if address.city.present?
      decedent['decedentAddress.state'] = address.state.strip if address.state.present?
      decedent['decedentAddress.zip'] = address.postalCode.strip if address.postalCode.present?
    end
    # Handle marital status
    decedent['maritalStatus.maritalStatus'] = MARITAL_STATUS.key(patient.maritalStatus) if MARITAL_STATUS.key(patient.maritalStatus)
    # The following are extensions
    patient.extension.each do |extension|
      if extension.url == 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'
        # Handle race
        code = extension.valueCodeableConcept&.coding&.first&.code
        if code && RACE_ETHNICITY_CODES.key(code)
          decedent['race.race.option'] = 'Known'
          decedent['race.race.specify'] = [RACE_ETHNICITY_CODES.key(code)].to_json
        end
      elsif extension.url == 'http://hl7.org/fhir/StructureDefinition/birthPlace'
        # Handle birth place
        address = extension.valueAddress
        if address
          decedent['placeOfBirth.zip'] = address.postalCode if address.postalCode.present?
          decedent['placeOfBirth.city'] = address.city if address.city.present?
          decedent['placeOfBirth.state'] = address.state if address.state.present?
        end
      elsif extension.url == 'http://hl7.org/fhir/StructureDefinition/patient-mothersMaidenName'
        # Handle mother's maiden name
        decedent['motherName.lastName'] = extension.valueString if extension.valueString.present?
      elsif extension.url == 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex'
        # Handle sex
        sex = if extension.valueCode == 'M'
                'Male'
              elsif extension.valueCode == 'F'
                'Female'
              elsif extension.valueCode == 'U'
                'Unknown'
              end
        decedent['sex.sex'] = sex if sex.present?
      end
    end

    decedent
  end


  #############################################################################
  # The below section is for consuming the FHIR death certifier information
  # that is included in a FHIR death record.
  #############################################################################

  # Returns certifier information in Nightingale form given a FHIR death record.
  def self.certifier(certifier_entry)
    practitioner = certifier_entry.resource
    certifier = {}

    # Handle name
    if practitioner.name && practitioner.name.length > 0
      name = practitioner.name.first
      certifier['personCompletingCauseOfDeathName.firstName'] = name.given.first if name.given && name.given.first.present?
      # All subsequent 'given' names will be combined and included as the 'middle name'
      certifier['personCompletingCauseOfDeathName.middleName'] = name.given.drop(1).join(' ') if name.given && name.given.drop(1).any? && !name.given.drop(1).join(' ').blank?
      # All 'family' names will be combined and included as the 'last name'
      if name.family.is_a?(Array)
        certifier['personCompletingCauseOfDeathName.lastName'] = name.family.join(' ') if name.family && name.family.any?
      else
        certifier['personCompletingCauseOfDeathName.lastName'] = name.family
      end 
      certifier['personCompletingCauseOfDeathName.suffix'] = name.suffix.join(' ') if name.suffix && name.suffix.any? && !name.suffix.join(' ').blank?
    end
    # Handle address
    if practitioner.address.present?
      address = practitioner.address.first
      certifier['personCompletingCauseOfDeathAddress.street'] = address.line.first if address.line && address.line.first.present?
      certifier['personCompletingCauseOfDeathAddress.city'] = address.city.strip if address.city.present?
      certifier['personCompletingCauseOfDeathAddress.state'] = address.state.strip if address.state.present?
      certifier['personCompletingCauseOfDeathAddress.zip'] = address.postalCode.strip if address.postalCode.present?
    end
    # Handle type
    certifier_lookup = {
      '434651000124107': 'Certifying Physician',
      '434641000124105': 'Pronouncing and Certifying Physician',
      '440051000124108': 'Medical Examiner/Coroner'
    }.stringify_keys
    if practitioner.extension && practitioner.extension.any?
      practitioner.extension.each do |extension|
        if extension.url == 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/certifier-type'
          certifier['certifierType.certifierType'] = certifier_lookup[extension.valueCoding.code] if certifier_lookup[extension.valueCoding.code]
        end
      end
    end
    # NOTE: Certifier qualification is not used in Nightingale

    certifier
  end


  #############################################################################
  # The below section is for consuming FHIR Conditions (causes of deaths)
  # that are included in a FHIR death record.
  #############################################################################

  # Consume FHIR death record Cause-of-Death-Condition.
  def self.cause_of_death_condition(cod_entry, index)
    cause = cod_entry.resource
    cod = {}
    if index == 0
      cod['cod.immediate'] = cause.text.div if cause.text && cause.text.div.present?
      cod['cod.immediateInt'] = cause.onsetString if cause.onsetString.present?
    else
      cod['cod.under' + index.to_s] = cause.text.div if cause.text && cause.text.div.present?
      cod['cod.under' + index.to_s + 'Int'] = cause.onsetString if cause.onsetString.present?
    end
    cod
  end


  #############################################################################
  # The below section is for consuming the various Observations that are
  # included in a FHIR death record.
  #############################################################################

  # Consume FHIR death record Actual-Or-Presumed-Date-Of-Death.
  def self.actual_or_presumed_date_of_death(entry)
    observation = {}
    dateTime = DateTime.parse(entry.resource.valueDateTime)
    observation['dateOfDeath.dateOfDeath'] = dateTime.strftime('%F')
    #observation['dateOfDeath.dateType'] = 'Actual'
    observation['timeOfDeath.timeOfDeath'] = dateTime.strftime('%H:%M')
    #observation['timeOfDeath.timeType'] = 'Actual'
    observation
  end

  # Consume FHIR death record Autopsy-Performed.
  def self.autopsy_performed(entry)
    observation = {}

    value = if entry.resource.valueBoolean == true
              'Yes'
            elsif entry.resource.valueBoolean == false
              'No'
            end

    observation['autopsyPerformed.autopsyPerformed'] = value
    observation
  end

  # Consume FHIR death record Autopsy-Results-Available.
  def self.autopsy_results_available(entry)
    observation = {}

    value = if entry.resource.valueBoolean == true
              'Yes'
            elsif entry.resource.valueBoolean == false
              'No'
            end

    observation['autopsyAvailableToCompleteCauseOfDeath.autopsyAvailableToCompleteCauseOfDeath'] = value
    observation
  end

  # Consume FHIR death record Date-Pronounced-Dead.
  def self.date_pronounced_dead(entry)
    observation = {}
    dateTime = DateTime.parse(entry.resource.valueDateTime)
    observation['datePronouncedDead.datePronouncedDead'] = dateTime.strftime('%F')
    observation['timePronouncedDead.timePronouncedDead'] = dateTime.strftime('%H:%M')
    observation
  end

  # Consume FHIR death record Death-Resulted-From-Injury-At-Work.
  def self.death_resulted_from_injury_at_work(entry)
    observation = {}

    value = if entry.resource.valueBoolean == true
              'Yes'
            elsif entry.resource.valueBoolean == false
              'No'
            end

    observation['deathResultedFromInjuryAtWork.deathResultedFromInjuryAtWork'] = value
    observation
  end

  # Consume FHIR death record Injury-Leading-To-Death-Associated-Trans.
  def self.injury_leading_to_death_associated_trans(entry)
    observation = {}
    # TODO: Nightingale does not collect this at the moment!
    observation
  end

  # Consume FHIR death record Manner-Of-Death.
  def self.manner_of_death(entry)
    observation = {}

    # Convert FHIR information for use in Nightingale
    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=0D3864B7-5330-410D-BC91-40C1C704BBA4
    # OID: 2.16.840.1.114222.4.11.6002
    lookup = {
      '38605008': 'Natural',
      '7878000': 'Accident',
      '44301001': 'Suicide',
      '27935005': 'Homicide',
      '185973002': 'Pending Investigation',
      '65037004': 'Could not be determined'
    }.stringify_keys

    observation['mannerOfDeath.mannerOfDeath'] = lookup[entry.resource.valueCodeableConcept.coding.first.code]
    observation
  end

  # Consume FHIR death record Medical-Examiner-Or-Coroner-Contacted.
  def self.medical_examiner_or_coroner_contacted(entry)
    observation = {}

    value = if entry.resource.valueBoolean == true
              'Yes'
            elsif entry.resource.valueBoolean == false
              'No'
            end

    observation['meOrCoronerContacted.meOrCoronerContacted'] = value
    observation
  end

  # Consume FHIR death record Timing-Of-Pregnancy-In-Relation-To-Death.
  def self.timing_of_pregnancy_in_relation_to_death(entry)
    observation = {}

    # Convert FHIR information for use in Nightingale
    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=C763809B-A38D-4113-8E28-126620B76C2F
    # OID: 2.16.840.1.114222.4.11.6003
    lookup = {
      'PHC1260': 'Not pregnant within past year',
      'PHC1261': 'Pregnant at time of death',
      'PHC1262': 'Not pregnant, but pregnant within 42 days of death',
      'PHC1263': 'Not pregnant, but pregnant 43 days to 1 year before death',
      'PHC1264': 'Unknown if pregnant within the past year',
      'N/A': 'Not pregnant within past year' # 'not applicable' is not shown in Nightingale, use 'Not pregnant within past year' instead
    }.stringify_keys

    observation['pregnancyStatus.pregnancyStatus'] = lookup[entry.resource.valueCodeableConcept.coding.first.code]
    observation
  end

  # Consume FHIR death record Tobacco-Use-Contributed-To-Death.
  def self.tobacco_use_contributed_to_death(entry)
    observation = {}

    # Convert FHIR information for use in Nightingale
    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=FF7F17AE-3D20-473D-9068-E77A08491242
    # OID: 2.16.840.1.114222.4.11.6004
    lookup = {
      '373066001': 'Yes',
      '373067005': 'No',
      '2931005': 'Probably',
      'UNK': 'Unknown',
      'NASK': 'Unknown' # 'not asked' is not shown in Nightingale, use 'Unkown' instead
    }.stringify_keys

    observation['didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath'] = lookup[entry.resource.valueCodeableConcept.coding.first.code]
    observation
  end


  #############################################################################
  # Lookup helpers
  #############################################################################

  MARITAL_STATUS = {
    'Married' => 'M',
    'Married but seperated' => 'M',
    'Widowed' => 'W',
    'Widowed (but not remarried)' => 'W',
    'Divorced (but not remarried)' => 'D',
    'Never married' => 'S',
    'Unknown' => 'UNK',
  }.stringify_keys

  RACE_ETHNICITY_CODES = {
    'White' => '2106-3',
    'Black or African American' => '2054-5',
    'American Indian or Alaskan Native' => '1002-5',
    'Asian' => '2028-5',
    'Asian Indian' => '2029-7',
    'Chinese' => '2034-7',
    'Filipino' => '2036-2',
    'Japanese' => '2039-6',
    'Korean' => '2040-4',
    'Vietnamese' => '2047-9',
    'Native Hawaiian' => '2079-2',
    'Guamanian' => '2087-5',
    'Chamorro' => '2088-3',
    'Samoan' => '2080-0',
    'Other Pacific Islander' => '2500-7'
  }.stringify_keys

end
