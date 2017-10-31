require 'test_helper'

class DeathRecordTest < ActiveSupport::TestCase
  setup do
    @dr = DeathRecord.find(1)
  end

  test 'death record steps are correct and in order' do
    assert @dr.steps.collect(&:name) == ["Identity", "Demographics", "Family", "Disposition", "F.D. Review", "Medical", "Physician Review", "Registration"]
  end

  test 'death record builds its contents (flat representation) correctly' do
    assert @dr.build_contents['fatherName.lastName'] == 'Example'
    assert @dr.build_contents['informantAddress.street'] == '3 Example St.'
    assert @dr.build_contents['placeOfDisposition.city'] == 'Lowell'
    assert @dr.build_contents['funeralFacility.state'] == 'Massachusetts'
  end

  test 'sepetate step contents' do
    assert @dr.separate_step_contents(@dr.contents)['Identity'].length == 0
    assert @dr.separate_step_contents(@dr.contents)['Family'].length == 2
    assert @dr.separate_step_contents(@dr.contents)['Disposition'].length == 6
  end

  test 'previous step is correct' do
    assert @dr.previous_step.name == 'Physician Review'
  end
end
