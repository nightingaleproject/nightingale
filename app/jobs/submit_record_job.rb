class SubmitRecordJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    record = DeathRecord.find(record_id)
    return if record.coding_message_id # Don't resubmit coded messages, anything else is ok (since we may want to recode)
    # Convert to FHIR/JSON using VRDR.HTTP microservice
    # TODO: Make service URL configurable
    contents = record.contents
    puts "Converting record #{record.id} to FHIR"
    response = RestClient.post "http://localhost:8080/json", contents.to_json, {content_type: 'application/nightingale'}
    fhir_record = JSON.parse(response.body)
    # Submit using Reference-Client-API service
    # TODO: Make service URL configurable
    if record.voided
      puts "Voiding record #{record.id}"
      url = "http://localhost:4300/record/void"
    elsif record.initially_submitted
      puts "Updating record #{record.id}"
      url = "http://localhost:4300/record/update"
    else
      puts "Submitting record #{record.id}"
      url = "http://localhost:4300/record/submission"
    end
    response = RestClient.post url, fhir_record.to_json, { content_type: 'application/json'}
    record.update_attributes(initially_submitted: true, currently_submitted: true)
  end
end
