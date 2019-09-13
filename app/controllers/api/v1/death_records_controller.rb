class Api::V1::DeathRecordsController < ActionController::API
  include ActionController::MimeResponds
  #before_action :doorkeeper_authorize!
  before_action :cors_headers

  # POST death_record
  def create
    respond_to do |format|
      physician_email = params[:physician_email]

      if !physician_email
        user = User.find_by(first_name: 'Example', last_name: 'Certifier')
      else
        user = User.find_for_authentication(email: physician_email)
      end

      contents = JSON.parse(request.body.string)

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

      format.json { render json: { status: :ok, message: 'Created ID: ' + @death_record.id.to_s } }
      format.xml { render xml: { status: :ok, message: 'Created ID: ' + @death_record.id.to_s } }
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
