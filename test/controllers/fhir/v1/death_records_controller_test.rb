require 'test_helper'

class Fhir::V1::DeathRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dr = DeathRecord.find(1)
  end

  test 'validate FHIR output' do
    assert FhirProducerHelper.to_fhir(@dr).validate.empty?
  end
end
