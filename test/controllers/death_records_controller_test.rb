require 'test_helper'

class DeathRecordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    bob = users(:bob)
    # Need to assign an actual role to bob.
    bob.add_role(:funeral_director)
    # Give bob all roles
    # rubocop:disable Style/PredicateName
    def bob.has_role?(*)
      true
    end
    # rubocop:enable Style/PredicateName
    sign_in bob
    @death_record = death_records(:one)
    @cause_of_death_1 = cause_of_deaths(:cod_one)
  end

  test 'should get index' do
    get death_record_url @death_record
    assert_response :success
  end

  test 'should create death_record' do
    assert_difference('DeathRecord.count') do
      post(
        death_records_url,
        params: {
          death_record: {
            place_of_death_facility_name: @death_record.place_of_death_facility_name,
            place_of_death_street_and_number: @death_record.place_of_death_street_and_number,
            place_of_death_apt: @death_record.place_of_death_apt,
            place_of_death_city: @death_record.place_of_death_city,
            place_of_death_state: @death_record.place_of_death_state,
            place_of_death_county: @death_record.place_of_death_county,
            place_of_death_zip_code: @death_record.place_of_death_zip_code,
            time_pronounced_dead: @death_record.time_pronounced_dead,
            date_pronounced_dead: @death_record.date_pronounced_dead,
            pronouncing_medical_certifier_license_number: @death_record.pronouncing_medical_certifier_license_number,
            pronouncing_medical_certifier_date_of_signature: @death_record.pronouncing_medical_certifier_date_of_signature,
            actual_or_presumed_date_of_death: @death_record.actual_or_presumed_date_of_death,
            actual_or_presumed_time_of_death: @death_record.actual_or_presumed_time_of_death,
            was_medical_examiner_or_coroner_contacted: @death_record.was_medical_examiner_or_coroner_contacted,
            was_an_autopsy_performed: @death_record.was_an_autopsy_performed,
            were_autopsy_findings_available: @death_record.were_autopsy_findings_available,
            did_tobacco_use_contribute_to_death: @death_record.did_tobacco_use_contribute_to_death,
            pregnancy_status: @death_record.pregnancy_status,
            manner_of_death: @death_record.manner_of_death,
            time_of_injury: @death_record.time_of_injury,
            date_of_injury: @death_record.date_of_injury,
            injury_at_work: @death_record.injury_at_work,
            place_of_injury: @death_record.place_of_injury,
            location_of_injury_state: @death_record.location_of_injury_state,
            location_of_injury_city: @death_record.location_of_injury_city,
            location_of_injury_street_and_number: @death_record.location_of_injury_street_and_number,
            location_of_injury_apt: @death_record.location_of_injury_apt,
            location_of_injury_zip_code: @death_record.location_of_injury_zip_code,
            description_of_injury_occurrence: @death_record.description_of_injury_occurrence,
            transportation_injury: @death_record.transportation_injury,
            transportation_injury_role: @death_record.transportation_injury_role,
            transportation_injury_role_specified: @death_record.transportation_injury_role_specified,
            certifier_type: @death_record.certifier_type,
            medical_certifier_first: @death_record.medical_certifier_first,
            medical_certifier_last: @death_record.medical_certifier_last,
            medical_certifier_state: @death_record.medical_certifier_state,
            medical_certifier_city: @death_record.medical_certifier_city,
            medical_certifier_street_and_number: @death_record.medical_certifier_street_and_number,
            medical_certifier_zip_code: @death_record.medical_certifier_zip_code,
            medical_certifier_title: @death_record.medical_certifier_title,
            medical_certifier_license_number: @death_record.medical_certifier_license_number,
            date_certified: @death_record.date_certified,
            cause_of_death: @death_record.cause_of_death
          }
        })
    end

    assert_redirected_to death_record_step_path(DeathRecord.last, WorkflowHelper.first_step_based_on_record(DeathRecord.last))
  end

  test 'should update death_record' do
    patch(
      death_record_url(@death_record),
      params: {
        death_record: {
          place_of_death_facility_name: @death_record.place_of_death_facility_name,
          place_of_death_street_and_number: @death_record.place_of_death_street_and_number,
          place_of_death_apt: @death_record.place_of_death_apt,
          place_of_death_city: @death_record.place_of_death_city,
          place_of_death_state: @death_record.place_of_death_state,
          place_of_death_county: @death_record.place_of_death_county,
          place_of_death_zip_code: @death_record.place_of_death_zip_code,
          time_pronounced_dead: @death_record.time_pronounced_dead,
          date_pronounced_dead: @death_record.date_pronounced_dead,
          pronouncing_medical_certifier_license_number: @death_record.pronouncing_medical_certifier_license_number,
          pronouncing_medical_certifier_date_of_signature: @death_record.pronouncing_medical_certifier_date_of_signature,
          actual_or_presumed_date_of_death: @death_record.actual_or_presumed_date_of_death,
          actual_or_presumed_time_of_death: @death_record.actual_or_presumed_time_of_death,
          was_medical_examiner_or_coroner_contacted: @death_record.was_medical_examiner_or_coroner_contacted,
          was_an_autopsy_performed: @death_record.was_an_autopsy_performed,
          were_autopsy_findings_available: @death_record.were_autopsy_findings_available,
          did_tobacco_use_contribute_to_death: @death_record.did_tobacco_use_contribute_to_death,
          pregnancy_status: @death_record.pregnancy_status,
          manner_of_death: @death_record.manner_of_death,
          time_of_injury: @death_record.time_of_injury,
          date_of_injury: @death_record.date_of_injury,
          injury_at_work: @death_record.injury_at_work,
          place_of_injury: @death_record.place_of_injury,
          location_of_injury_state: @death_record.location_of_injury_state,
          location_of_injury_city: @death_record.location_of_injury_city,
          location_of_injury_street_and_number: @death_record.location_of_injury_street_and_number,
          location_of_injury_apt: @death_record.location_of_injury_apt,
          location_of_injury_zip_code: @death_record.location_of_injury_zip_code,
          description_of_injury_occurrence: @death_record.description_of_injury_occurrence,
          transportation_injury: @death_record.transportation_injury,
          transportation_injury_role: @death_record.transportation_injury_role,
          transportation_injury_role_specified: @death_record.transportation_injury_role_specified,
          certifier_type: @death_record.certifier_type,
          medical_certifier_first: @death_record.medical_certifier_first,
          medical_certifier_last: @death_record.medical_certifier_last,
          medical_certifier_state: @death_record.medical_certifier_state,
          medical_certifier_city: @death_record.medical_certifier_city,
          medical_certifier_street_and_number: @death_record.medical_certifier_street_and_number,
          medical_certifier_zip_code: @death_record.medical_certifier_zip_code,
          medical_certifier_title: @death_record.medical_certifier_title,
          medical_certifier_license_number: @death_record.medical_certifier_license_number,
          date_certified: @death_record.date_certified
        }
      })
    assert_redirected_to death_record_url(@death_record)
  end
end
