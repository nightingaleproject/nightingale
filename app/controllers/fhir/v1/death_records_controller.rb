class Fhir::V1::DeathRecordsController < ActionController::Base
  #before_action :doorkeeper_authorize! # TODO: Add back when done testing!

  # Create a new record using the given FHIR
  def create
    respond_to do |format|
      # TODO
      format.json { render json: { status: 'ok', message: "Not implemented!" } }
    end
  end

  # Update the record using the given FHIR
  def update
    respond_to do |format|
      # TODO
      format.json { render json: { status: 'ok', message: "Not implemented!" } }
    end
  end

  # Return the record in FHIR format
  def show
    respond_to do |format|
      # Fetch the requested record
      death_record = DeathRecord.find(params[:id])

      # Start a new FHIR record
      fhir_record = FHIR::Bundle.new

      # Add basic info to the FHIR record
      FhirHelper.basic_info(death_record, fhir_record)

      # TODO: Add more info?

      format.json { render json: fhir_record.to_json }
    end
  end

end
