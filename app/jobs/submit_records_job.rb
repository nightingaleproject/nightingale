class SubmitRecordsJob < ApplicationJob
  queue_as :default

  def perform()
    death_records = DeathRecord.all
    death_records.each do |record|
      # Convert to FHIR/JSON using microservice
      # TODO: We temporarily use the record ID as the certificate number and remove a field that causes the service to fail
      contents = record.contents.merge({ certificateNumber: record.id }).except("decedentName.akas")
      response = RestClient.post "http://localhost:8080/json", contents.to_json, {content_type: 'application/nightingale'}
      fhir_record = JSON.parse(response.body)
      # Package in FHIR message
      message_id = record.message_id
      record_id = fhir_record['id']
      bundle = {
        resourceType: "Bundle",
        type: "message",
        id: message_id,
        timestamp: DateTime.now.to_s,
        entry: []
      }
      event_uri = if record.voided
                    "http://nchs.cdc.gov/vrdr_submission_void"
                  elsif record.submitted
                    "http://nchs.cdc.gov/vrdr_submission_update"
                  else
                    "http://nchs.cdc.gov/vrdr_submission"
                  end
      header = {
        resourceType: "MessageHeader",
        id: message_id,
        timestamp: DateTime.now.to_s,
        eventUri: event_uri,
        destination: [{ endpoint: "http://nchs.cdc.gov/vrdr_submission" }],
        source: { endpoint: "https://example-jurisdiction.gov/vital_records" },
        focus: [{ reference: "urn:uuid:#{record_id}" }]
      }
      bundle[:entry] << { resource: header }
      if record.voided
        void_record = {
          resourceType: "Parameters",
          parameter: [{ name: "cert_no", valueString: record.id },
                      { name: "state_id", valueString: "WA" }]
        }
        bundle[:entry] << { resource: void_record }
      else
        bundle[:entry] << { resource: fhir_record }
      end
      # Submit to message API server
      response = RestClient.post "http://localhost:4000/messages", bundle.to_json, { content_type: 'application/json'}
      # TODO: The submitted field should eventually be updated based on a receipt message
      record.update_columns(submitted: true) # Bypass callbacks so that message_id doesn't get updated
    end
  end
end
