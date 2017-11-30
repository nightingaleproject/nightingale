class Api::V1::DeathRecordsController < ActionController::Base # TODO: Change me!
  before_action :doorkeeper_authorize!

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
      # TODO
      format.json { render json: { status: 'ok', message: "Not implemented!" } }
    end
  end

end
