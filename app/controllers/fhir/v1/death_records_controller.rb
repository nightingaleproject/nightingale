require 'fhirdeathrecord'
require 'json'

class Fhir::V1::DeathRecordsController < ActionController::API
  include ActionController::MimeResponds
  #before_action :doorkeeper_authorize!
  before_action :cors_headers

  # Create a new record using the given FHIR json.
  def create
    # Handle given FHIR in either JSON or XML format
    contents = if request.content_type.include? 'json'
      response = RestClient.post "http://#{VrdrHelper.get_host}/nightingale", request.body.string, {content_type: 'application/fhir+json'}
      JSON.parse(response.body)
    elsif request.content_type.include? 'xml'
      response = RestClient.post "http://#{VrdrHelper.get_host}/nightingale", request.body.string, {content_type: 'application/fhir+xml'}
      JSON.parse(response.body)
    end

    # Grab the certifier
    user = User.find_by(first_name: 'Example', last_name: 'Certifier')

    # Create new record
    workflow = Workflow.where(initiator_role: user.roles.first.name).order('created_at').last
    step_flow = workflow.step_flows.first
    @death_record = DeathRecord.new(creator: user,
                                    owner: user,
                                    workflow: workflow,
                                    step_flow: step_flow)
    step_status = StepStatus.create(death_record: @death_record,
                                    current_step: step_flow.current_step,
                                    next_step: step_flow.next_step,
                                    previous_step: step_flow.previous_step)
    @death_record.step_status = step_status
    @death_record.save
    steps_content_hash = @death_record.separate_step_contents(contents)
    @death_record.steps.each do |step|
      if steps_content_hash[step.name]
        StepContent.update_or_create_new(death_record: @death_record,
                                          step: step,
                                          contents: steps_content_hash[step.name],
                                          editor: user)
      end
    end
    @death_record.notify = true
    @death_record.save(validate: false)

    message = { status: :ok, message: 'Created ID: ' + @death_record.id.to_s }

    respond_to do |format|
      format.json { render json: message }
      format.xml { render xml: message }
    end
  end

  # Update the record using the given FHIR json.
  def update
    respond_to do |format|
      format.json { render json: { status: :not_implemented } }
    end
  end

  # Return the record in FHIR format (as json or xml).
  def show
    respond_to do |format|
      # Fetch the requested record
      death_record = current_user.owned_death_records.find(params[:id])
      #death_record = DeathRecord.find(params[:id])

      # Grab the certifier
      #user_first, user_last = FhirDeathRecord::Consumer.certifier_name(resource)
      user = User.find_by(first_name: 'Example', last_name: 'Certifier')
      certifier_id = user.id

      # Add basic info to the FHIR record
      fhir_record = FhirDeathRecord::Producer.to_fhir({'contents': death_record.contents, id: death_record.id, certifier_id: certifier_id})

      format.json { render json: fhir_record.to_json }
      format.xml { render xml: fhir_record.to_xml }
    end
  end

  # Handle OPTIONS requests for CORS preflight
  def options
    render plain: ''
  end

  private

  # Allow cross-origin requests
  def cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  end

end
