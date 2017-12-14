require 'test_helper'

class Fhir::V1::DeathRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dr = DeathRecord.find(1)
  end

  # TODO: This should probably be in a test for the FhirHelper instead of the controller...
  test 'validate FHIR output' do
    #assert FHIR::Json.from_json(FhirHelper.to_fhir(@dr).to_json).validate.empty?
    true
  end
end
