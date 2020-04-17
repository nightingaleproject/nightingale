require 'test_helper'

class Fhir::V1::DeathRecordsControllerTest < ActionDispatch::IntegrationTest
    test 'importing an XML death record is successful' do
    # This record is generated using the Canary
    # "Generate Synthetic Death Records" option
    assert_difference 'DeathRecord.count', +1 do
        post fhir_v1_death_records_url,
             as: :xml,
             params: File.read(Rails.root.join('test/fixtures/files/example-record.xml')),
             headers: { 'CONTENT_TYPE': 'application/xml' }
        assert :success
    end
  end
end
