class Step < ApplicationRecord
  has_many :step_statuses
  has_many :step_flows
  has_many :step_contents

  # Returns the fields and their properties that make up this step.
  def fields
    self.jsonschema.nil? ? [] : self.jsonschema['properties']
  end

  # Returns a hash of allowed params for use when updating step contents
  # from the front end for this step.
  def whitelist
    gather_params(self.jsonschema) if self.jsonschema.present? && self.jsonschema.key?('properties')
  end

  # Get the StepContent that answers this Step for the given DeathRecord.
  def step_content_obj(death_record)
    step_contents.find_by(step: self, death_record: death_record)
  end

  # Get the StepContent's content that answers this Step for the given
  # DeathRecord.
  def step_content(death_record)
    contents = step_content_obj(death_record)
    contents.contents unless contents.nil?
  end

  def as_json(options = {})
    if options[:death_record]
      contents = step_content_obj(options[:death_record])
      active = options[:death_record].step_status.current_step == self
    end
    if options[:death_record] && options[:user]
      editable = options[:death_record].step_editable?(options[:user], self)
    end
    {
      id: self.id,
      name: self.name,
      abbrv: self.abbrv,
      description: self.description,
      version: self.version,
      jsonschema: self.jsonschema,
      uischema: self.uischema,
      icon: self.icon,
      type: self.step_type,
      empty: contents.nil?,
      contents: contents.nil? ? {} : contents,
      editable: editable,
      active: active
    }
  end

  private

  # Recursive function that takes a JSONSchema and builds a structured
  # hash of allowed parameters.
  def gather_params(hash, keys = [])
    if hash['properties'].present?
      hash['properties'].keys.each do |key|
        sub_params = gather_params(hash['properties'][key]) unless hash['properties'].nil?
        if sub_params.empty?
          keys.push(key)
        else
          params = {}
          params[key] = sub_params
          keys.push(params)
        end
      end
    end
    return keys
  end
end
