class Fhir::V1::MessagesController < ActionController::API

  respond_to :json

  def create
    # Handle the incoming message; this is just a quick demo, so super lightweight and informal
    json = JSON.parse(request.body.read)
    header = json['entry'].first['resource']
    event_uri = header['eventUri']
    record_message_id = header['response']['identifier']

    case event_uri
    when "http://nchs.cdc.gov/vrdr_acknowledgement"
      # Find the record for which this message is being acknowledged and record the acknowledgement
      record = DeathRecord.find_by_message_id(record_message_id)
      if record
        # We use update_column so we don't trigger a new message_id generation
        record.update_column(:acknowledgement_message_id, header['id'])
      end

    when "http://nchs.cdc.gov/vrdr_coding"
      # Find the record for which this message has codes and record the codes
      record = DeathRecord.find_by_message_id(record_message_id)
      if record
        # TODO: Abstract out the code to pull this apart
        coding_result = json['entry'].last['resource']
        # Use jsonpath to pull out values
        record_cause_codes = JsonPath.new('$.parameter[?(@.name==record_cause_of_death)]..code').on(coding_result)
        # TODO: Get the underlying and entity codes too
        # We use update_column so we don't trigger a new message_id generation
        record.update_columns(coding_message_id: header['id'], record_cause_codes: record_cause_codes.join(' '))
      end

    end

  end

end
