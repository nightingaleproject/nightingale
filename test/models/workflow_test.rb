require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  setup do
    @wf1 = Workflow.find_by(name: 'fd_starts')
    @wf2 = Workflow.find_by(name: 'physician_starts')
  end

  test 'demo workflows have correct ordered steps' do
    assert @wf1.steps[0].name == 'Identity'
    assert @wf1.steps[1].name == 'Demographics'
    assert @wf1.steps[2].name == 'Family'
    assert @wf1.steps[3].name == 'Disposition'
    assert @wf1.steps[4].name == 'F.D. Review'
    assert @wf1.steps[5].name == 'Medical'
    assert @wf1.steps[6].name == 'Physician Review'
    assert @wf1.steps[7].name == 'Registration'
    assert @wf2.steps[0].name == 'Medical'
    assert @wf2.steps[1].name == 'Physician Review'
    assert @wf2.steps[2].name == 'Identity'
    assert @wf2.steps[3].name == 'Demographics'
    assert @wf2.steps[4].name == 'Family'
    assert @wf2.steps[5].name == 'Disposition'
    assert @wf2.steps[6].name == 'F.D. Review'
    assert @wf2.steps[7].name == 'Physician Re-review'
    assert @wf2.steps[8].name == 'Registration'
  end
end
