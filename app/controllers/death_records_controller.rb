# Death Records Controller
class DeathRecordsController < ApplicationController
  before_action :authenticate_user!, :set_death_record, only: [:show, :update]

  include Wicked::Wizard
  steps :identity, :demographics, :disposition, :medical

  def index
    @death_records = DeathRecordsPolicy::Scope.new(current_user, DeathRecord).resolve  
  end

  def show
    @death_record
    render_wizard
  end

  def create
    @death_record = DeathRecord.new
    @death_record.user_id = current_user[:id]
    @death_record.save
    redirect_to death_record_path(:identity, death_record_id: @death_record.id)
  end

  def update
    @death_record.update(death_record_params)
    redirect_to @death_record
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_death_record
    @death_record = DeathRecord.find(params[:death_record_id])
  end

  # Never trust parameters from the internet, only allow the white list through.
  def death_record_params
    params.require(:death_record).permit(:place_of_death_facility_name,
                                         :place_of_death_street_number,
                                         :place_of_death_appt_number,
                                         :place_of_death_city,
                                         :place_of_death_state,
                                         :place_of_death_country,
                                         :place_of_death_zip_code,
                                         :time_pronounced_dead,
                                         :date_pronounced_dead,
                                         :pronouncing_medical_certifier_license_number,
                                         :pronouncing_medical_certifier_date_of_signature,
                                         :actual_or_presumed_date_of_death,
                                         :actual_or_presumed_time_of_death,
                                         :was_medical_examiner_or_coroner_contacted,
                                         :was_an_autopsy_performed,
                                         :were_autopsy_findings_available,
                                         :did_tobacco_use_contribute_to_death,
                                         :pregnancy_status,
                                         :manner_of_death,
                                         :time_of_injury,
                                         :date_of_injury,
                                         :injury_at_work,
                                         :place_of_injury,
                                         :location_of_injury_state,
                                         :location_of_injury_city,
                                         :location_of_injury_street_and_number,
                                         :location_of_injury_apartment_number,
                                         :location_of_injury_zip_code,
                                         :description_of_injury_occurrence,
                                         :transportation_injury,
                                         :transportation_injury_role,
                                         :transportation_injury_role_specified,
                                         :certifier_type,
                                         :medical_certifier_first,
                                         :medical_certifier_last,
                                         :medical_certifier_state,
                                         :medical_certifier_city,
                                         :medical_certifier_street_and_number,
                                         :medical_certifier_zip_code,
                                         :medical_certifier_title,
                                         :medical_certifier_license_number,
                                         :date_certified)
  end
end
