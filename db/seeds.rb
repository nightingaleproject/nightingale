###############################################################################
# Record creation for geographic data used for structured data input
###############################################################################

Rake::Task['geo:load_geo_fixtures'].invoke

###############################################################################
# Record creation for Workflow data
###############################################################################

Workflow.create!(name: 'funeral_director')
Workflow.create!(name: 'physician')
Workflow.create!(name: 'other')

###############################################################################
# Record creation for Step data
###############################################################################

Step.create!(name: 'identity')
Step.create!(name: 'demographics')
Step.create!(name: 'disposition')
Step.create!(name: 'send_to_medical_professional')
Step.create!(name: 'medical')
Step.create!(name: 'send_to_registrar')
Step.create!(name: 'send_to_funeral_director')

###############################################################################
# Record creation for Workflow Steps Navigation
###############################################################################

WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'funeral_director').first.id, current_step: Step.where(name: 'identity').first, next_step: Step.where(name: 'demographics').first, transition_order: 1)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'funeral_director').first.id, current_step: Step.where(name: 'demographics').first, next_step: Step.where(name: 'disposition').first, transition_order: 2)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'funeral_director').first.id, current_step: Step.where(name: 'disposition').first, next_step: Step.where(name: 'send_to_medical_professional').first, transition_order: 3)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'funeral_director').first.id, current_step: Step.where(name: 'send_to_medical_professional').first, next_step: Step.where(name: 'medical').first, transition_order: 4)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'funeral_director').first.id, current_step: Step.where(name: 'medical').first, next_step: Step.where(name: 'send_to_registrar').first, transition_order: 5)

WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'physician').first.id, current_step: Step.where(name: 'medical').first, next_step: Step.where(name: 'send_to_funeral_director').first, transition_order: 1)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'physician').first.id, current_step: Step.where(name: 'send_to_funeral_director').first, next_step: Step.where(name: 'identity').first, transition_order: 2)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'physician').first.id, current_step: Step.where(name: 'identity').first, next_step: Step.where(name: 'demographics').first, transition_order: 3)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'physician').first.id, current_step: Step.where(name: 'demographics').first, next_step: Step.where(name: 'disposition').first, transition_order: 4)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'physician').first.id, current_step: Step.where(name: 'disposition').first, next_step: Step.where(name: 'send_to_registrar').first, transition_order: 5)

WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'other').first.id, current_step: Step.where(name: 'identity').first, next_step: Step.where(name: 'demographics').first, transition_order: 1)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'other').first.id, current_step: Step.where(name: 'demographics').first, next_step: Step.where(name: 'disposition').first, transition_order: 2)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'other').first.id, current_step: Step.where(name: 'disposition').first, next_step: Step.where(name: 'medical').first, transition_order: 3)
WorkflowStepNavigation.create!(workflow_id: Workflow.where(name: 'other').first.id, current_step: Step.where(name: 'medical').first, next_step: Step.where(name: 'send_to_registrar').first, transition_order: 4)
