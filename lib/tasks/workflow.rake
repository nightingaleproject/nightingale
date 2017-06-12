# Rake tasks for configuring Nightingale workflows.
namespace :nightingale do
  namespace :workflows do
    desc %(Builds/updates the workflow models that define workflows
    in Nightingale.

    NOTE: This process is version "smart". This means that if a single
    Step's JSONSchema is changed since the last run, a new Step model
    for that step will be created with a new version hash, and a new
    Workflow will be created that utilizes the changed step, as well
    as the older unchanged steps.

    Configuration files used by this process are located at:

    nightingale
    |
    \---workflows
        |
        +---workflows.json
        |
        \---steps
            |
            +---example_JSONSchema.json (referenced by workflows.json)
            +---example_UISchema.json (referenced by workflows.json)

    $ rake nightingale:workflows:build)
    task build: :environment do
      require 'json'

      print 'Building workflows... '

      # Grab workflows configuration
      workflows_config_json = File.read('workflows/workflows.json')
      workflows_config = JSON.parse(workflows_config_json)

      step_versions = {}

      # Create Steps (being version smart)
      workflows_config['steps'].each do |step_def|
        # Grab JSONSchema and UISchema for this step
        step_jsonschema_json = File.read(step_def['jsonschema']) if step_def['jsonschema']
        step_uischema_json = File.read(step_def['uischema']) if step_def['uischema']

        # Create a version string by combining a digest of the schema contents
        version = Digest::SHA512.hexdigest(step_jsonschema_json.to_s + step_uischema_json.to_s)

        step_versions[step_def['name']] = version

        # If this step does not yet exist, create a Step representation of it.
        # If the step does exist, make a new version of the existing Step.
        Step.find_or_create_by!(name: step_def['name'], version: version) do |step|
          step.name = step_def['name']
          step.abbrv = step_def['abbrv']
          step.description = step_def['description']
          step.version = version
          step.jsonschema = JSON.parse(step_jsonschema_json) if step_jsonschema_json
          step.uischema = JSON.parse(step_uischema_json) if step_uischema_json
          step.icon = step_def['icon']
          step.step_type = step_def['step_type']
        end
      end

      # Create Workflows and StepFlow
      workflows_config['workflows'].each do |workflow_def|
        # Create a new Workflow
        workflow = Workflow.create!(
          name: workflow_def['name'],
          description: workflow_def['description'],
          initiator_role: workflow_def['initiator_role']
        )

        # Create the StepFlows that describe how to progress
        # through this specific workflow.
        step_index = 0
        workflow_def['roles'].each do |role_def|
          role_def['steps'].each do |step|
            StepFlow.create!(
              workflow: workflow,
              current_step_role: role_def['name'],
              send_to_role: step['send_to_role'],
              current_step: Step.where(name: step['name'], version: step_versions[step['name']]).order('created_at').last,
              transition_order: step_index
            )
            step_index += 1
          end
        end

        # Add next and previous Step direction for this Workflow's
        # StepFlows by traversing their order.
        flows = workflow.step_flows
        flows.each_with_index do |flow, index|
          # Build forward link
          if flows.length - 1 > index && flows[index + 1].current_step.present?
            flow.update!(next_step: flows[index + 1].current_step)
          end
          # Build backwards link
          if index != 0 && flows[index - 1].current_step.present?
            flow.update!(previous_step: flows[index - 1].current_step)
          end
        end
      end

      # Build RolePermissions
      workflows_config['permissions'].each do |role, permissions|
        RolePermission.find_or_create_by!(
          role: role,
          can_start_record: permissions['can_start_record'],
          can_register_record: permissions['can_register_record'],
          can_request_edits: permissions['can_request_edits']
        )
      end

      puts 'Done!'
    end
  end
end
