require 'test_helper'

class FhirProducerHelperTest < ActiveSupport::TestCase
  setup do
    @dr = DeathRecord.find(1) # TODO: Use a better fixture for this
  end

  test 'validate FHIR output' do
    assert FhirProducerHelper.to_fhir(@dr).validate.empty?
  end
end