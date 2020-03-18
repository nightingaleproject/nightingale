class Fhir::V1::MessagesController < ActionController::API

  respond_to :json

  def create
    # Handle the incoming message; this is just a quick demo, so super lightweight and informal
    json_string = request.body.read
    json = JSON.parse(json_string)
    header = json['entry'].first['resource']
    event_uri = header['eventUri']
    record_message_id = header['response']['identifier']

    raise "Cannot determine message id" unless record_message_id

    # Save every message for display for demo purposes only
    Message.create(message_id: header['id'], json: json_string)

    case event_uri
    when "http://nchs.cdc.gov/vrdr_acknowledgement"
      # Find the record for which this message is being acknowledged and record the acknowledgement
      record = DeathRecord.find_by_message_id(record_message_id)
      if record
        record.update_attributes(acknowledgement_message_id: header['id'])
      end

    when "http://nchs.cdc.gov/vrdr_coding"
      # Find the record for which this message has codes and record the codes
      record = DeathRecord.find_by_message_id(record_message_id)
      if record
        # TODO: Abstract out the code to pull this apart
        coding_result = json['entry'].last['resource']
        # Use jsonpath to pull out values
        underlying_cause_codes = JsonPath.new('$.parameter[?(@.name==underlying_cause_of_death)]..code').on(coding_result)
        record_cause_codes = JsonPath.new('$.parameter[?(@.name==record_cause_of_death)]..code').on(coding_result)
        entity_cause_codes = JsonPath.new('$.parameter[?(@.name==entity_axis_code)]..code').on(coding_result)
        record.update_attributes(coding_message_id: header['id'],
                                 underlying_cause_code: underlying_cause_codes.first,
                                 record_cause_codes: record_cause_codes.join(' '),
                                 entity_cause_codes: entity_cause_codes.join(' '))
      end

    else

      raise "Unknown event URI #{event_uri} received"

    end

  end

end
