# Helper module for exporting Nightingale death records as FHIR
module FhirProducerHelper

  # Given a Nightingale death record, build and return an equivalent FHIR death record bundle
  def self.to_fhir(death_record)
    # Catagorize values by their LOINC codes (this helps us convert Nightingale's internal
    # death record structure to something that more directly maps to the FHIR death
    # record model)
    death_record_loinc = death_record.to_loinc

    # Create a new bundle
    fhir_record = FHIR::Bundle.new(
      'resourceType' => 'Bundle',
      'id' => death_record.id.to_s,
      'type' => 'document',
    )

    # Create the death record composition
    # https://nightingaleproject.github.io/fhir-death-record/#/volume2/Death-Record-Composition
    composition = FHIR::Composition.new

    # Set the composition type
    composition.type = FHIR::CodeableConcept.new(
      'coding' => {
        'code' => '64297-5',
        'display' => 'Death certificate',
        'system' => 'http://loinc.org'
      }
    )

    # Create a section for the composition
    section = FHIR::Composition::Section.new

    # Set section code
    section.code = FHIR::CodeableConcept.new(
      'coding' => {
        'code' => '69453-9',
        'display' => 'Cause of death',
        'system' => 'http://loinc.org'
      }
    )

    # Create and add the decedent (Patient)
    subject = FhirProducerHelper.death_record_decedent(death_record)
    composition.subject = subject.fullUrl
    fhir_record.entry << subject

    # Create and add the certifier (Practitioner)
    author = FhirProducerHelper.death_certifier(death_record)
    composition.author = author.fullUrl
    fhir_record.entry << author

    # Create and add the cause of death(s) (Conditions)
    cause_of_deaths = []
    cause_of_deaths << FhirProducerHelper.cause_of_death_condition(death_record_loinc, 0, subject)
    cause_of_deaths << FhirProducerHelper.cause_of_death_condition(death_record_loinc, 1, subject)
    cause_of_deaths << FhirProducerHelper.cause_of_death_condition(death_record_loinc, 2, subject)
    cause_of_deaths << FhirProducerHelper.cause_of_death_condition(death_record_loinc, 3, subject)
    cause_of_deaths.compact!

    # Add the cause of death references to the compositon section
    cause_of_deaths.each do |cod|
      section.entry << cod.fullUrl
    end

    # Add the cause of deaths themselves to the bundle
    fhir_record.entry.push(*cause_of_deaths)

    # Create the observations
    observations = []
    observations << FhirProducerHelper.actual_or_presumed_date_of_death(death_record_loinc)
    observations << FhirProducerHelper.autopsy_performed(death_record_loinc)
    observations << FhirProducerHelper.autopsy_results_available(death_record_loinc)
    observations << FhirProducerHelper.date_pronounced_dead(death_record_loinc)
    observations << FhirProducerHelper.death_resulted_from_injury_at_work(death_record_loinc)
    observations << FhirProducerHelper.injury_leading_to_death_associated_trans(death_record_loinc) # TODO: Nigthingale does not support this!
    observations << FhirProducerHelper.manner_of_death(death_record_loinc)
    observations << FhirProducerHelper.medical_examiner_or_coroner_contacted(death_record_loinc)
    observations << FhirProducerHelper.timing_of_pregnancy_in_relation_to_death(death_record_loinc)
    observations << FhirProducerHelper.tobacco_use_contributed_to_death(death_record_loinc)
    observations.compact!

    # Add the observation references to the compositon section
    observations.each do |obs|
      section.entry << obs.fullUrl
    end

    # Add the observations themselves to the bundle
    fhir_record.entry.push(*observations)

    # Add the section to the composition
    composition.section = section

    # Finally, add the composition itself to the bundle and return the bundle
    fhir_record.entry.unshift(composition) # Make composition the first bundle entry
    fhir_record
  end


  #############################################################################
  # The below section is for building a Patient (the decedent) that is
  # included in a FHIR death record compositon.
  #############################################################################

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Death-Record-Decedent
  #
  # This entry contains a FHIR Patient describing Death-Record-Decedent.
  def self.death_record_decedent(death_record)
    # Patient options
    options = {}
    # Decedent name
    name = {}
    name['given'] = [death_record.contents['decedentName.firstName']] unless death_record.contents['decedentName.firstName'].blank?
    unless death_record.contents['decedentName.middleName'].blank?
      name['given'] = [] unless name['given']
      name['given'] << death_record.contents['decedentName.middleName']
    end
    name['family'] = [death_record.contents['decedentName.lastName']] unless death_record.contents['decedentName.lastName'].blank?
    name['use'] = 'official'
    options['name'] = [name] unless name.empty?
    # Decedent D.O.B.
    options['birthDate'] = death_record.contents['dateOfBirth.dateOfBirth'] unless death_record.contents['dateOfBirth.dateOfBirth'].blank?
    # Decedent is deceased
    options['deceasedBoolean'] = true
    # Date and time of death
    options['deceasedDateTime'] = DateTime.strptime(death_record.contents['dateOfDeath.dateOfDeath'] + '-' + death_record.contents['timeOfDeath.timeOfDeath'], '%F-%H:%M').to_s unless death_record.contents['dateOfDeath.dateOfDeath'].blank? || death_record.contents['timeOfDeath.timeOfDeath'].blank?
    # Decedent's address
    line = death_record.contents['decedentAddress.street']
    line += ' ' + death_record.contents['decedentAddress.apt'] unless line.nil? || death_record.contents['decedentAddress.apt'].blank?
    address = {}
    address['line'] = [line] unless line.blank?
    address['city'] = death_record.contents['decedentAddress.city'] unless death_record.contents['decedentAddress.city'].blank?
    address['state'] = death_record.contents['decedentAddress.state'] unless death_record.contents['decedentAddress.state'].blank?
    address['postalCode'] = death_record.contents['decedentAddress.zip'] unless death_record.contents['decedentAddress.zip'].blank?
    options['address'] = address
    # Decedent's marital status
    options['maritalStatus'] = MARITAL_STATUS[death_record.contents['maritalStatus.maritalStatus']] if MARITAL_STATUS[death_record.contents['maritalStatus.maritalStatus']]
    options['extension'] = []
    # Decedent race, TODO: Need to support all chosen options
    options['extension'] << {
      'url' => 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race',
      'valueCodeableConcept' => {
        'coding' => [{
          'display' => death_record.contents['race.race.specify'].gsub(/[^0-9a-z]/i, ' ').squish,
          'code' => RACE_ETHNICITY_CODES[death_record.contents['race.race.specify'].gsub(/[^0-9a-z,]/i, ' ')&.split(',')&.first.squish],
          'system' => 'http://hl7.org/fhir/v3/Race'
        }]
      }
    } if death_record.contents['race.race.specify']
    # Decedent place of birth
    options['extension'] << {
      'url' => 'http://hl7.org/fhir/StructureDefinition/birthPlace',
      'valueAddress' => FHIR::Address.new({postalCode: death_record.contents['placeOfBirth.zip'], city: death_record.contents['placeOfBirth.city'], state: death_record.contents['placeOfBirth.state']}).to_hash
    } if death_record.contents['placeOfBirth.city'] || death_record.contents['placeOfBirth.state'] || death_record.contents['placeOfBirth.zip']
    # Decedent's mother's maiden name
    options['extension'] << {
      'url' => 'http://hl7.org/fhir/StructureDefinition/patient-mothersMaidenName',
      'valueString' => death_record.contents['motherName.lastName']
    } if death_record.contents['motherName.lastName']
    # Decedent's birth sex
    options['extension'] << {
      'url' => 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex',
      'valueCode' => death_record.contents['sex.sex']&.chars&.first
    } if death_record.contents['sex.sex']
    patient = FHIR::Patient.new(options)

    # Package patient into entry and return
    entry = FHIR::Bundle::Entry.new
    resource_id = SecureRandom.uuid
    entry.fullUrl = "urn:uuid:#{resource_id}"
    entry.resource = patient
    entry
  end


  #############################################################################
  # The below section is for building a Practitioner (the death certifier)
  # that is included in a FHIR death record compositon.
  #############################################################################

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Death-Certifier
  #
  # This entry contains a FHIR Practitioner describing Death-Certifier.
  def self.death_certifier(death_record)
    # New practitioner
    practitioner = FHIR::Practitioner.new

    extension = FHIR::Extension.new
    extension.url = 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/certifier-type'

    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=1A195A5D-F911-46C6-A58B-4146B722BAB0
    # OID: 2.16.840.1.114222.4.11.6001
    nightingale_certifier_lookup = {
      'Certifying Physician': {concept: '434651000124107', system: 'http://snomed.info/sct', display: 'Certifying physician-To the best of my knowledge, death occurred due to the cause(s) and manner stated.'},
      'Pronouncing and Certifying Physician': {concept: '434641000124105', system: 'http://snomed.info/sct', display: 'Pronouncing & Certifying physician-To the best of my knowledge, death occurred at the time, date, and place, and due to the cause(s) and manner stated.'},
      'Medical Examiner/Coroner': {concept: '440051000124108', system: 'http://snomed.info/sct', display: 'Medical Examiner/Coroner-On the basis of examination, and/or investigation, in my opinion, death occurred at the time, date, and place, and due to the cause(s) and manner stated.'}
    }.stringify_keys
    certifier_type = nightingale_certifier_lookup[death_record.contents['certifierType.certifierType']]
    extension.valueCoding = FHIR::Coding.new(
      'code' => certifier_type[:concept],
      'display' => certifier_type[:display],
      'system' => certifier_type[:system]
    ) unless certifier_type.blank?
    practitioner.extension = extension


    # Certifier name
    name = {}
    name['family'] = death_record.contents['personCompletingCauseOfDeathName.lastName'] unless death_record.contents['personCompletingCauseOfDeathName.lastName'].blank?
    name['given'] = [death_record.contents['personCompletingCauseOfDeathName.firstName']] unless death_record.contents['personCompletingCauseOfDeathName.firstName'].blank?
    unless death_record.contents['personCompletingCauseOfDeathName.middleName'].blank?
      name['given'] = [] unless name['given']
      name['given'] << death_record.contents['personCompletingCauseOfDeathName.middleName']
    end
    name['suffix'] = death_record.contents['personCompletingCauseOfDeathName.suffix'] unless death_record.contents['personCompletingCauseOfDeathName.suffix'].blank?
    practitioner.name = FHIR::HumanName.new(name) unless name.empty?

    # Certifier address
    address = {}
    line = death_record.contents['personCompletingCauseOfDeathAddress.street']
    line += ' ' + death_record.contents['personCompletingCauseOfDeathAddress.apt'] unless line.nil? || death_record.contents['personCompletingCauseOfDeathAddress.apt'].blank?
    address['line'] = [line] unless line.blank?
    address['city'] = death_record.contents['personCompletingCauseOfDeathAddress.city'] unless death_record.contents['personCompletingCauseOfDeathAddress.city'].blank?
    address['state'] = death_record.contents['personCompletingCauseOfDeathAddress.state'] unless death_record.contents['personCompletingCauseOfDeathAddress.state'].blank?
    address['postalCode'] = death_record.contents['personCompletingCauseOfDeathAddress.zip'] unless death_record.contents['personCompletingCauseOfDeathAddress.zip'].blank?
    practitioner.address = FHIR::Address.new(address) unless address.empty?

    # Qualification
    qualification = FHIR::Practitioner::Qualification.new
    qualification.identifier = FHIR::Identifier.new(
      'use' => 'official'#,
      #'value' => 'MD' # TODO: How to determine this within Nightingale (maybe use system role?)
    )
    qualification.issuer = FHIR::Identifier.new # TODO: How to determine this within Nightingale
    practitioner.qualification = qualification

    # Package practitioner into entry and return
    entry = FHIR::Bundle::Entry.new
    resource_id = SecureRandom.uuid
    entry.fullUrl = "urn:uuid:#{resource_id}"
    entry.resource = practitioner
    entry
  end


  #############################################################################
  # The below section is for building Conditions (causes of deaths) that are
  # included in a FHIR death record compositon.
  #############################################################################

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Cause-of-Death-Condition
  #
  # This entry contains a FHIR Condition describing Cause-of-Death-Condition.
  def self.cause_of_death_condition(death_record_loinc, cod_index, subject)
    # New condition
    condition = FHIR::Condition.new

    # Grab causes and onsets
    causes = death_record_loinc['69453-9']
    return nil if causes.nil? || causes[cod_index].nil? # Return nil if no cause
    onsets = death_record_loinc['69440-6']

    # Grab the causes (and potential onset) for this condition
    cause = causes[cod_index]
    onset = onsets[cod_index] # It's reasonable that this could be nil

    # Set cause
    narrative = FHIR::Narrative.new
    narrative.status = 'additional' # Narrative may contain additional information not found in structured data
    narrative.div = cause
    condition.text = narrative

    # Set onset if it exists
    condition.onsetString = onset unless onset.blank?

    # Set decedent reference
    condition.subject = subject.fullUrl

    # Package condition into entry and return
    entry = FHIR::Bundle::Entry.new
    resource_id = SecureRandom.uuid
    entry.fullUrl = "urn:uuid:#{resource_id}"
    entry.resource = condition
    entry
  end


  #############################################################################
  # The below section is for building the various Observations that make up
  # a FHIR death record compositon.
  #############################################################################

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Actual-Or-Presumed-Date-Of-Death
  #
  # This entry contains a FHIR Observation describing Actual-Or-Presumed-Date-Of-Death.
  def self.actual_or_presumed_date_of_death(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '81956-5',
      display: 'Date and time of death',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Actual-Or-Presumed-Date-Of-Death'
    }

    # Convert Nightingale input to the proper FHIR specific output
    obs_value = {
      type: 'valueDateTime',
      value: value.to_s
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Performed
  #
  # This entry contains a FHIR Observation describing Autopsy-Performed.
  def self.autopsy_performed(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '85699-7',
      display: 'Autopsy was performed',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Performed'
    }

    # Convert Nightingale input to the proper FHIR specific output
    nightingale_lookup = {
      'Yes': true,
      'No': false,
    }.stringify_keys
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Results-Available
  #
  # This entry contains a FHIR Observation describing Autopsy-Results-Available.
  def self.autopsy_results_available(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '69436-4',
      display: 'Autopsy results available',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Results-Available'
    }

    # Convert Nightingale input to the proper FHIR specific output
    nightingale_lookup = {
      'Yes': true,
      'No': false,
    }.stringify_keys
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Date-Pronounced-Dead
  #
  # This entry contains a FHIR Observation describing Date-Pronounced-Dead.
  def self.date_pronounced_dead(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '80616-6',
      display: 'Date and time pronounced dead',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Date-Pronounced-Dead'
    }

    # Convert Nightingale input to the proper FHIR specific output
    obs_value = {
      type: 'valueDateTime',
      value: value.to_s
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Death-Resulted-From-Injury-At-Work
  #
  # This entry contains a FHIR Observation describing Death-Resulted-From-Injury-At-Work.
  def self.death_resulted_from_injury_at_work(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '69444-8',
      display: 'Did death result from injury at work',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Death-Resulted-From-Injury-At-Work'
    }

    # Convert Nightingale input to the proper FHIR specific output
    nightingale_lookup = {
      'Yes': true,
      'No': false
    }.stringify_keys
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Injury-Leading-To-Death-Associated-Trans
  #
  # This entry contains a FHIR Observation describing Injury-Leading-To-Death-Associated-Trans.
  def self.injury_leading_to_death_associated_trans(death_record_loinc)
    # TODO: Nightingale does not collect this at the moment! Defaulting to "Other"!
    value = 'Other'

    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '69448-9',
      display: 'Injury leading to death associated with transportation event',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Injury-Leading-To-Death-Associated-Trans'
    }

    # Convert Nightingale input to the proper FHIR specific output
    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=F148DC82-63C3-40B1-A7D2-D7AD78416D4A
    # OID: 2.16.840.1.114222.4.11.6005
    nightingale_lookup = {
      'Driver/Operator': {concept: '236320001', system: 'http://snomed.info/sct', display: 'Driver/Operator'},
      'Passenger': {concept: '257500003', system: 'http://snomed.info/sct', display: 'Passenger'},
      'Pedestrian': {concept: '257518000', system: 'http://snomed.info/sct', display: 'Pedestrian'},
      'Other': {concept: 'OTH', system: 'http://hl7.org/fhir/v3/NullFlavor', display: 'Other'}
    }.stringify_keys
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Manner-Of-Death
  #
  # This entry contains a FHIR Observation describing Manner-Of-Death.
  def self.manner_of_death(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '69449-7',
      display: 'Manner of death',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Manner-Of-Death'
    }

    # Convert Nightingale input to the proper FHIR specific output
    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=0D3864B7-5330-410D-BC91-40C1C704BBA4
    # OID: 2.16.840.1.114222.4.11.6002
    nightingale_lookup = {
      'Natural': {concept: '38605008', system: 'http://snomed.info/sct', display: 'Natural'},
      'Accident': {concept: '7878000', system: 'http://snomed.info/sct', display: 'Accident'},
      'Suicide': {concept: '44301001', system: 'http://snomed.info/sct', display: 'Suicide'},
      'Homicide': {concept: '27935005', system: 'http://snomed.info/sct', display: 'Homicide'},
      'Pending Investigation': {concept: '185973002', system: 'http://snomed.info/sct', display: 'Pending Investigation'},
      'Could not be determined': {concept: '65037004', system: 'http://snomed.info/sct', display: 'Could not be determined'}
    }.stringify_keys
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Medical-Examiner-Or-Coroner-Contacted
  #
  # This entry contains a FHIR Observation describing Medical-Examiner-Or-Coroner-Contacted.
  def self.medical_examiner_or_coroner_contacted(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '74497-9',
      display: 'Medical examiner or coroner was contacted',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Medical-Examiner-Or-Coroner-Contacted'
    }

    # Convert Nightingale input to the proper FHIR specific output
    nightingale_lookup = {
      'Yes': true,
      'No': false
    }.stringify_keys
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Timing-Of-Pregnancy-In-Relation-To-Death
  #
  # This entry contains a FHIR Observation describing Timing-Of-Pregnancy-In-Relation-To-Death.
  def self.timing_of_pregnancy_in_relation_to_death(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '69442-2',
      display: 'Timing of recent pregnancy in relation to death',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Timing-Of-Pregnancy-In-Relation-To-Death'
    }

    # Convert Nightingale input to the proper FHIR specific output
    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=C763809B-A38D-4113-8E28-126620B76C2F
    # OID: 2.16.840.1.114222.4.11.6003
    nightingale_lookup = {
      'Not pregnant within past year': {concept: 'PHC1260', system: 'PHIN VS (CDC Local Coding System)', display: 'Not pregnant within past year'},
      'Pregnant at time of death': {concept: 'PHC1261', system: 'PHIN VS (CDC Local Coding System)', display: 'Pregnant at time of death'},
      'Not pregnant, but pregnant within 42 days of death': {concept: 'PHC1262', system: 'PHIN VS (CDC Local Coding System)', display: 'Not pregnant, but pregnant within 42 days of death'},
      'Not pregnant, but pregnant 43 days to 1 year before death': {concept: 'PHC1263', system: 'PHIN VS (CDC Local Coding System)', display: 'Not pregnant, but pregnant 43 days to 1 year before death'},
      'Unknown if pregnant within the past year': {concept: 'PHC1264', system: 'PHIN VS (CDC Local Coding System)', display: 'Unknown if pregnant within the past year'},
    }.stringify_keys
    debugger unless nightingale_lookup[value]
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Tobacco-Use-Contributed-To-Death
  #
  # This entry contains a FHIR Observation describing Tobacco-Use-Contributed-To-Death.
  def self.tobacco_use_contributed_to_death(death_record_loinc)
    # Coding informations for this observation (helps figure out which part of the record this is)
    obs_code = {
      code: '69443-0',
      display: 'Did tobacco use contribute to death',
      system: 'http://loinc.org'
    }

    # Grab death record value
    value = death_record_loinc[obs_code[:code]]
    return nil unless value # Don't construct observation if the record doesn't have this value

    # Metadata information for this observation
    obs_meta = {
      'profile' => 'https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Tobacco-Use-Contributed-To-Death'
    }

    # Convert Nightingale input to the proper FHIR specific output
    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=FF7F17AE-3D20-473D-9068-E77A08491242
    # OID: 2.16.840.1.114222.4.11.6004
    nightingale_lookup = {
      'Yes': {concept: '373066001', system: 'http://snomed.info/sct', display: 'Yes'},
      'No': {concept: '373067005', system: 'http://snomed.info/sct', display: 'No'},
      'Probably': {concept: '2931005', system: 'http://snomed.info/sct', display: 'Probably'},
      'Unknown': {concept: 'UNK', system: 'http://hl7.org/fhir/v3/NullFlavor', display: 'Unknown'}
    }.stringify_keys
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value, obs_meta)
  end

  # FHIR Observation Entry builder
  def self.observation(obs_code, obs_value, obs_meta)
    # New observation
    observation = FHIR::Observation.new

    # Add code (CodeableConcept)
    observation.code = FHIR::CodeableConcept.new(
      'coding' => {
        'code' => obs_code[:code],
        'display' => obs_code[:display],
        'system' => obs_code[:system]
      }
    )

    # Add metadata
    observation.meta = obs_meta

    # Handle type of value
    if obs_value[:type] == 'valueCodeableConcept' # Add valueCodeableConcept (CodeableConcept)
      observation.valueCodeableConcept = FHIR::CodeableConcept.new(
        'coding' => {
          'code' => obs_value[:code],
          'display' => obs_value[:display],
          'system' => obs_value[:system]
        }
      )
    elsif obs_value[:type] == 'valueBoolean' # Add valueBoolean
      observation.valueBoolean = obs_value[:value]
    elsif obs_value[:type] == 'valueDateTime' # Add valueDateTime
      # We need to make sure the date is set as a proper FHIR valueDateTime,
      # thus we need to handle a few situations that might occur given
      # Nightingale user entry.
      # TODO: This needs some polishing...
      date = Date.strptime(obs_value[:value], '%Y-%m-%d') rescue nil # Try date only
      date = Date.parse(obs_value[:value]) unless date # Try regular datetime
      observation.valueDateTime = date.to_datetime.to_s
    end

    # Package obervation into entry and return
    entry = FHIR::Bundle::Entry.new
    resource_id = SecureRandom.uuid
    entry.fullUrl = "urn:uuid:#{resource_id}"
    entry.resource = observation
    entry
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
