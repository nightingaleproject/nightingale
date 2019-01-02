require 'fhirdeathrecord'
# Importing Controller
class ImportingController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_is_admin

  def index
  end

  def error
    @error_msg = params['error_msg']
  end

  def upload_fhir
    begin
        uploaded_io = params[:fhir]
        File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
        fhir_str = File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename)).read

        if params['fhir'].content_type == 'application/json'
        resource = FHIR::Json.from_json(fhir_str)
        elsif params['fhir'].content_type == 'application/xml'
        resource = FHIR::Xml.from_xml(fhir_str)
        end

        # Grab the certifier
        user = User.find_by(first_name: 'Example', last_name: 'Certifier')

        # Convert FHIR bundle to Nightingale style flat contents
        contents = FhirDeathRecord::Consumer.from_fhir(resource)

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
    rescue StandardError => e
        redirect_to :controller => 'importing', :action => 'error', :error_msg => e
        return
    end

    redirect_to :controller => 'death_records', :action => 'index'
  end

  private

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
