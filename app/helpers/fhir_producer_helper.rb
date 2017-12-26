# Helper module for exporting Nightingale death records as FHIR.
module FhirProducerHelper

  # Given a Nightingale death record, build an equal FHIR death record bundle.
  def self.to_fhir(death_record)




    # # https://nightingaleproject.github.io/fhir-death-record/#/volume2/Death-Record-Composition
    # composition = FHIR::Composition.new


    # comp_type = FHIR::CodeableConcept.new(
    #   'coding' => {
    #     'code' => '64297-5',
    #     'display' => 'Death certificate',
    #     'system' => 'http://loinc.org'
    #   }
    # )

    # # Todo...

    # # Package composition into entry and return
    # entry = FHIR::Bundle::Entry.new
    # resource_id = SecureRandom.uuid
    # entry.fullUrl = "urn:uuid:#{resource_id}"
    # entry.resource = composition
    # entry
  end


  #############################################################################
  # The below section is for building a Patient (the decedent) that is
  # included in a FHIR death record compositon.
  #############################################################################

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Death-Record-Decedent
  #
  # This entry contains a FHIR Patient describing Death-Record-Decedent.
  def self.death_record_decedent(code, value)
  end

  # FHIR Patient Entry builder
  def self.patient
    # New patient
    patient = FHIR::Patient.new

    # Todo...

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
  def self.death_certifier
  end

  # FHIR Practitioner Entry builder
  def self.practitioner
    # New practitioner
    practitioner = FHIR::Practitioner.new

    # Todo...

    # Package practitioner into entry and return
    entry = FHIR::Bundle::Entry.new
    resource_id = SecureRandom.uuid
    entry.fullUrl = "urn:uuid:#{resource_id}"
    entry.resource = practitioner
    entry
  end


  #############################################################################
  # The below section is for building a Condition (cause of death) that is
  # included in a FHIR death record compositon.
  #############################################################################

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Cause-of-Death-Condition
  #
  # This entry contains a FHIR Condition describing Cause-of-Death-Condition.
  def self.cause_of_death_condition
  end

  # FHIR Condition Entry builder
  def self.condition
    # New condition
    condition = FHIR::Condition.new

    # Todo...

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
  def self.actual_or_presumed_date_of_death(value)
    obs_code = {
      code: '81956-5',
      display: 'Date and time of death',
      system: 'http://loinc.org'
    }

    obs_value = {
      type: 'valueDateTime',
      value: value.to_s
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Performed
  #
  # This entry contains a FHIR Observation describing Autopsy-Performed.
  def self.autopsy_performed(value)
    obs_code = {
      code: '85699-7',
      display: 'Autopsy was performed',
      system: 'http://loinc.org'
    }

    nightingale_lookup = {
      'Yes': true,
      'No': false,
    }
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Autopsy-Results-Available
  #
  # This entry contains a FHIR Observation describing Autopsy-Results-Available.
  def self.autopsy_results_available(value)
    obs_code = {
      code: '69436-4',
      display: 'Autopsy results available',
      system: 'http://loinc.org'
    }

    nightingale_lookup = {
      'Yes': true,
      'No': false,
    }
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Date-Pronounced-Dead
  #
  # This entry contains a FHIR Observation describing Date-Pronounced-Dead.
  def self.date_pronounced_dead(value)
    obs_code = {
      code: '80616-6',
      display: 'Date and time pronounced dead',
      system: 'http://loinc.org'
    }

    obs_value = {
      type: 'valueDateTime',
      value: value.to_s
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Death-Resulted-From-Injury-At-Work
  #
  # This entry contains a FHIR Observation describing Death-Resulted-From-Injury-At-Work.
  def self.death_resulted_from_injury_at_work(value)

    # TODO: Nightingale does not collect this at the moment! Defaulting to "Unkown"!
    value = 'Unkown'

    obs_code = {
      code: '69444-8',
      display: 'Did death result from injury at work',
      system: 'http://loinc.org'
    }

    nightingale_lookup = {
      'Yes': true,
      'No': false,
      # TODO: valueBoolean seems to only be valid if true or false; how to handle "Unkown"? Defaulting to false for now...
      'Unkown': false
    }
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Injury-Leading-To-Death-Associated-Trans
  #
  # This entry contains a FHIR Observation describing Injury-Leading-To-Death-Associated-Trans.
  def self.injury_leading_to_death_associated_trans(value)

    # TODO: Nightingale does not collect this at the moment! Defaulting to "Other"!
    value = 'Other'

    obs_code = {
      code: '69448-9',
      display: 'Injury leading to death associated with transportation event',
      system: 'http://loinc.org'
    }

    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=F148DC82-63C3-40B1-A7D2-D7AD78416D4A
    # OID: 2.16.840.1.114222.4.11.6005
    nightingale_lookup = {
      'Driver/Operator': {concept: '236320001', system: 'http://snomed.info/sct', display: 'Driver/Operator'},
      'Passenger': {concept: '257500003', system: 'http://snomed.info/sct', display: 'Passenger'},
      'Pedestrian': {concept: '257518000', system: 'http://snomed.info/sct', display: 'Pedestrian'},
      'Other': {concept: 'OTH', system: 'http://hl7.org/fhir/v3/NullFlavor', display: 'Other'}
    }
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Manner-Of-Death
  #
  # This entry contains a FHIR Observation describing Manner-Of-Death.
  def self.manner_of_death(value)
    obs_code = {
      code: '69449-7',
      display: 'Manner of death',
      system: 'http://loinc.org'
    }

    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=0D3864B7-5330-410D-BC91-40C1C704BBA4
    # OID: 2.16.840.1.114222.4.11.6002
    nightingale_lookup = {
      'Natural': {concept: '38605008', system: 'http://snomed.info/sct', display: 'Natural'},
      'Accident': {concept: '7878000', system: 'http://snomed.info/sct', display: 'Accident'},
      'Suicide': {concept: '44301001', system: 'http://snomed.info/sct', display: 'Suicide'},
      'Homicide': {concept: '27935005', system: 'http://snomed.info/sct', display: 'Homicide'},
      'Pending Investigation': {concept: '185973002', system: 'http://snomed.info/sct', display: 'Pending Investigation'},
      'Could not be determined': {concept: '65037004', system: 'http://snomed.info/sct', display: 'Could not be determined'}
    }
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Medical-Examiner-Or-Coroner-Contacted
  #
  # This entry contains a FHIR Observation describing Medical-Examiner-Or-Coroner-Contacted.
  def self.medical_examiner_or_coroner_contacted(value)
    obs_code = {
      code: '74497-9',
      display: 'Medical examiner or coroner was contacted',
      system: 'http://loinc.org'
    }

    nightingale_lookup = {
      'Yes': true,
      'No': false,
      # TODO: valueBoolean seems to only be valid if true or false; how to handle "Unkown"? Defaulting to false for now...
      'Unkown': false
    }
    obs_value = {
      type: 'valueBoolean',
      value: nightingale_lookup[value]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Timing-Of-Pregnancy-In-Relation-To-Death
  #
  # This entry contains a FHIR Observation describing Timing-Of-Pregnancy-In-Relation-To-Death.
  def self.timing_of_pregnancy_in_relation_to_death(value)
    obs_code = {
      code: '69442-2',
      display: 'Timing of recent pregnancy in relation to death',
      system: 'http://loinc.org'
    }

    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=C763809B-A38D-4113-8E28-126620B76C2F
    # OID: 2.16.840.1.114222.4.11.6003
    nightingale_lookup = {
      'Not pregnant within past year': {concept: 'PHC1260', system: 'PHIN VS (CDC Local Coding System)', display: 'Not pregnant within past year'},
      'Pregnant at time of death': {concept: 'PHC1261', system: 'PHIN VS (CDC Local Coding System)', display: 'Pregnant at time of death'},
      'Not pregnant, but pregnant within 42 days of death': {concept: 'PHC1262', system: 'PHIN VS (CDC Local Coding System)', display: 'Not pregnant, but pregnant within 42 days of death'},
      'Not pregnant, but pregnant 43 days to 1 year before death': {concept: 'PHC1263', system: 'PHIN VS (CDC Local Coding System)', display: 'Not pregnant, but pregnant 43 days to 1 year before death'},
      'Unknown if pregnant within the past year': {concept: 'PHC1264', system: 'PHIN VS (CDC Local Coding System)', display: 'Unknown if pregnant within the past year'},
    }
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # Returns a FHIR entry that covers:
  # https://github.com/nightingaleproject/fhir-death-record/StructureDefinition/Tobacco-Use-Contributed-To-Death
  #
  # This entry contains a FHIR Observation describing Tobacco-Use-Contributed-To-Death.
  def self.tobacco_use_contributed_to_death(value)
    obs_code = {
      code: '69443-0',
      display: 'Did tobacco use contribute to death',
      system: 'http://loinc.org'
    }

    # See: https://phinvads.cdc.gov/vads/ViewValueSet.action?id=FF7F17AE-3D20-473D-9068-E77A08491242
    # OID: 2.16.840.1.114222.4.11.6004
    nightingale_lookup = {
      'Yes': {concept: '373066001', system: 'http://snomed.info/sct', display: 'Yes'},
      'No': {concept: '373067005', system: 'http://snomed.info/sct', display: 'No'},
      'Probably': {concept: '2931005', system: 'http://snomed.info/sct', display: 'Probably'},
      'Unknown': {concept: 'UNK', system: 'http://hl7.org/fhir/v3/NullFlavor', display: 'Unknown'}
    }
    obs_value = {
      type: 'valueCodeableConcept',
      code: nightingale_lookup[value][:concept],
      display: nightingale_lookup[value][:display],
      system: nightingale_lookup[value][:system]
    }

    # Construct and return this entry
    FhirProducerHelper.observation(obs_code, obs_value)
  end

  # FHIR Observation Entry builder
  def self.observation(obs_code, obs_value)
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

    # Handle type of value
    if obs_value[:type] == 'valueCodeableConcept'
      # Add valueCodeableConcept (CodeableConcept)
      observation.valueCodeableConcept = FHIR::CodeableConcept.new(
        'coding' => {
          'code' => obs_value[:code],
          'display' => obs_value[:display],
          'system' => obs_value[:system]
        }
      )
    elsif obs_value[:type] == 'valueBoolean'

      # TODO: Might need to do something more here...

      # Add valueBoolean
      observation.valueBoolean = obs_value[:value]
    elsif obs_value[:type] == 'valueDateTime'
      # Add valueDateTime

      # TODO: Might need to do something more here...

      observation.valueDateTime = obs_value[:value]
    end

    # Package obervation into entry and return
    entry = FHIR::Bundle::Entry.new
    resource_id = SecureRandom.uuid
    entry.fullUrl = "urn:uuid:#{resource_id}"
    entry.resource = observation
    entry
  end

end
