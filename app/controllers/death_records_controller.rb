# Death Records Controller
class DeathRecordsController < ApplicationController
  before_action :authenticate_user!, :set_death_record, only: [:show, :edit, :update, :destroy]

  # GET /death_records
  # GET /death_records.json
  def index
    @death_records = DeathRecordsPolicy::Scope.new(current_user, DeathRecord).resolve  
  end

  # GET /death_records/1
  # GET /death_records/1.json
  def show
  end

  # GET /death_records/new
  def new
    @death_record = DeathRecord.new
    @death_record.user_id = current_user[:id]
    if @death_record.save
      redirect_to edit_death_record_path(@death_record), id: @death_record.id
    else
      redirect_to index_death_record_path
    end
  end

  # GET /death_records/1/edit
  def edit
  end

  # POST /death_records
  # POST /death_records.json
  def create
    @death_record = DeathRecord.new(death_record_params)

    respond_to do |format|
      if @death_record.save
        format.html { redirect_to @death_record }
        format.json { render :show, status: :created, location: @death_record }
      else
        format.html { render :new }
        format.json { render json: @death_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /death_records/1
  # PATCH/PUT /death_records/1.json
  def update
    respond_to do |format|
      if @death_record.update(death_record_params)
        format.html { redirect_to @death_record }
        format.json { render :show, status: :ok, location: @death_record }
      else
        format.html { render :edit }
        format.json { render json: @death_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /death_records/1
  # DELETE /death_records/1.json
  def destroy
    @death_record.destroy
    respond_to do |format|
      format.html { redirect_to death_records_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_death_record
    @death_record = DeathRecord.find(params[:id])
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
