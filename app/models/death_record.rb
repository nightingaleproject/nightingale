# Death Record model
class DeathRecord < ApplicationRecord
  # TODO: Add Join table for owner_id and record_id (To track History)
  audited only: :owner_id
  has_many :cause_of_death, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :cause_of_death
  belongs_to :user
  has_one :user_token

  # TODO: Comment here.
  # TODO: Combine form_step and record_status
  # Looks like form_step is used as the last step completed while record_status is the next step.
  attr_accessor :form_step

  # Identity fields required
  with_options if: -> { required_for_step?(:identity) } do |step|
    step.validates :first_name, presence: true
    step.validates :last_name, presence: true
    step.validates :social_security_number, presence: true
    step.validates :street, presence: true
    step.validates :city, presence: true
    step.validates :state, presence: true
    step.validates :county, presence: true
    step.validates :zip_code, presence: true
    step.validates :inside_city_limits, presence: true
    step.validates :father_first_name, presence: true
    step.validates :father_last_name, presence: true
    step.validates :mother_first_name, presence: true
    step.validates :mother_last_name, presence: true
  end

  # Demographics fields required
  with_options if: -> { required_for_step?(:demographics) } do |step|
    step.validates :sex, presence: true
    step.validates :date_of_birth, presence: true
    step.validates :birthplace_city, presence: true
    step.validates :birthplace_state, presence: true
    step.validates :birthplace_country, presence: true
    step.validates :ever_in_us_armed_forces, presence: true
    step.validates :marital_status_at_time_of_death, presence: true
    step.validates :education, presence: true
    step.validates :hispanic_origin, presence: true
    step.validates :race, presence: true
    step.validates :usual_occupation, presence: true
    step.validates :kind_of_business, presence: true
  end

  # Disposition fields required
  with_options if: -> { required_for_step?(:disposition) } do |step|
    step.validates :method_of_disposition, presence: true
    step.validates :place_of_disposition, presence: true
    step.validates :place_of_disposition_city, presence: true
    step.validates :place_of_disposition_state, presence: true
    step.validates :funeral_facility_name, presence: true
    step.validates :funeral_facility_street_and_number, presence: true
    step.validates :funeral_facility_city, presence: true
    step.validates :funeral_facility_state, presence: true
    step.validates :funeral_facility_zip, presence: true
    step.validates :funeral_facility_county, presence: true
    step.validates :funeral_director_license_number, presence: true
    step.validates :informants_name_first, presence: true
    step.validates :informants_name_last, presence: true
    step.validates :informants_mailing_address_street_and_number, presence: true
    step.validates :informants_mailing_address_city, presence: true
    step.validates :informants_mailing_address_state, presence: true
    step.validates :informants_mailing_address_zip_code, presence: true
    step.validates :informants_mailing_address_county, presence: true
  end

  # Medical fields required
  with_options if: -> { required_for_step?(:medical) } do |step|
    step.validates :place_of_death_type, presence: true
    step.validates :place_of_death_facility_name, presence: true
    step.validates :place_of_death_street_number, presence: true
    step.validates :place_of_death_city, presence: true
    step.validates :place_of_death_state, presence: true
    step.validates :place_of_death_zip_code, presence: true
    step.validates :place_of_death_county, presence: true
    step.validates :date_pronounced_dead, presence: true
    step.validates :time_pronounced_dead, presence: true
    step.validates :pronouncing_medical_certifier_license_number, presence: true
    step.validates :pronouncing_medical_certifier_date_of_signature, presence: true
    step.validates :actual_or_presumed_date_of_death, presence: true
    step.validates :type_of_date_of_death, presence: true
    step.validates :actual_or_presumed_time_of_death, presence: true
    step.validates :type_of_time_of_death, presence: true
    step.validates :was_medical_examiner_or_coroner_contacted, presence: true
    step.validates :was_an_autopsy_performed, presence: true
    step.validates :were_autopsy_findings_available, presence: true
    # TODO: Validate first cause of death field.
    # step.validates :cause, presense: true
    # step.validates :interval_to_death, presense: true
    step.validates :did_tobacco_use_contribute_to_death, presence: true
    step.validates :pregnancy_status, presence: true
    step.validates :manner_of_death, presence: true
    step.validates :medical_certifier_first, presence: true
    step.validates :medical_certifier_last, presence: true
    step.validates :medical_certifier_street_and_number, presence: true
    step.validates :medical_certifier_city, presence: true
    step.validates :medical_certifier_state, presence: true
    step.validates :medical_certifier_zip_code, presence: true
    step.validates :medical_certifier_county, presence: true
    step.validates :medical_certifier_license_number, presence: true
    step.validates :certifier_type, presence: true
    step.validates :date_certified, presence: true
  end

  def required_for_step?(step)
    return true if record_status.nil?
    return true if APP_CONFIG[creator_role].index(step.to_s) <= APP_CONFIG[creator_role].index(form_step)
  end
end
