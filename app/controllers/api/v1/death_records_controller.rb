class Api::V1::DeathRecordsController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception
  before_action :doorkeeper_authorize!

  # POST death_record
  def create
    respond_to do |format|
      # create death record
      physician_email = params[:physician_email]

      if !physician_email
        msg = { status: 'failure', message: 'Bad physician email' }
      else
        physician = User.find_for_authentication(email: physician_email)
        workflow = Workflow.where(initiator_role: physician.roles.first.name).order('created_at').last
        step_flow = workflow.step_flows.first
        @death_record = DeathRecord.new(creator: physician,
                                        owner: physician,
                                        workflow: workflow,
                                        step_flow: step_flow)

        # Create and and set a StepStatus for this DeathRecord.
        step_status = StepStatus.create(death_record: @death_record,
                                        current_step: step_flow.current_step,
                                        next_step: step_flow.next_step,
                                        previous_step: step_flow.previous_step)
        @death_record.step_status = step_status
        @death_record.save

        steps_content_hash = @death_record.separate_step_contents(params[:contents])
        @death_record.steps.each do |step|
          if steps_content_hash[step.name]
            StepContent.update_or_create_new(death_record: @death_record,
                                             step: step,
                                             contents: steps_content_hash[step.name],
                                             editor: physician)
          end
        end

        Rails.logger.debug 'Saving new decedent'
        # save but do not validate for now, as validation will not pass since
        # not all data will be in place
        # TBD:  Consider validation for this scenario
        @death_record.save(validate: false)
        msg = { status: 'ok', message: "Successfully added new death record with ID: #{@death_record.id}" }
      end

      format.json { render json: msg }
    end
  end

end
