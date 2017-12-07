class Fhir::V1::DeathRecordsController < ActionController::Base
  #before_action :doorkeeper_authorize! # TODO: Add back when done testing!

  # Create a new record using the given FHIR json.
  def create
    respond_to do |format|
      # TODO: Looking for FHIR bundle in 'data' key, this probably will change...
      input_json = params.permit(:contents)[:contents]

      # # Convert FHIR bundle to Nightingale-style flat contents
      # contents = FhirHelper.from_fhir(input_json)

      # # Create death record
      # physician_email = params.permit(:physician_email)[:physician_email]

      # if !physician_email
      #   msg = { status: 'failure', message: 'Bad physician email' }
      # else
      #   physician = User.find_for_authentication(email: physician_email)
      #   workflow = Workflow.where(initiator_role: physician.roles.first.name).order('created_at').last
      #   step_flow = workflow.step_flows.first
      #   @death_record = DeathRecord.new(creator: physician,
      #                                   owner: physician,
      #                                   workflow: workflow,
      #                                   step_flow: step_flow)

      #   # Create and and set a StepStatus for this DeathRecord
      #   step_status = StepStatus.create(death_record: @death_record,
      #                                   current_step: step_flow.current_step,
      #                                   next_step: step_flow.next_step,
      #                                   previous_step: step_flow.previous_step)
      #   @death_record.step_status = step_status
      #   @death_record.save
      #   steps_content_hash = @death_record.separate_step_contents(contents)
      #   @death_record.steps.each do |step|
      #     if steps_content_hash[step.name]
      #       StepContent.update_or_create_new(death_record: @death_record,
      #                                        step: step,
      #                                        contents: steps_content_hash[step.name],
      #                                        editor: physician)
      #     end
      #   end

      #   @death_record.save(validate: false)
      #   msg = { status: 'ok', message: "Successfully added new death record with ID: #{@death_record.id}" }
      # end
      format.json { render json: 'TODO' }
    end
  end

  # Update the record using the given FHIR json.
  def update
    respond_to do |format|
      # TODO
      format.json { render json: { status: 'ok', message: 'Not implemented!' } }
    end
  end

  # Return the record in FHIR format (as json or xml).
  def show
    respond_to do |format|
      # Fetch the requested record
      death_record = DeathRecord.find(params[:id])

      # Add basic info to the FHIR record
      fhir_record = FhirProducerHelper.to_fhir(death_record)

      format.json { render json: fhir_record.to_json }
      format.xml { render xml: fhir_record.to_xml }
    end
  end

end
