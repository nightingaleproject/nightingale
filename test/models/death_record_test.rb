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

  test 'seperate step contents' do
    assert @dr.separate_step_contents(@dr.contents)['Identity'].length == 1
    assert @dr.separate_step_contents(@dr.contents)['Family'].length == 2
    assert @dr.separate_step_contents(@dr.contents)['Disposition'].length == 6
  end

  test 'previous step is correct' do
    assert @dr.previous_step.name == 'Physician Review'
  end

  test 'converting a record to LOINC codes' do
    assert @dr.to_loinc == {"45392-8"=>"Person", "45393-6"=>"Middle", "45394-4"=>"Example", "45395-1"=>"", "21840-4"=>"1"}
  end

  test 'update a record from LOINC' do
    @dr.update_from_loinc({"45392-8"=>"Other", "45394-4"=>"Person", "21840-4"=>"2"})
    assert @dr.build_contents['decedentName.firstName'] == 'Other'
    assert @dr.build_contents['decedentName.lastName'] == 'Person'
    assert @dr.build_contents['sex.sex'] == 'Female'
  end
end
