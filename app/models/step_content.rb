class StepContent < ApplicationRecord
  belongs_to :step
  belongs_to :death_record
  belongs_to :editor, class_name: 'User'
  has_one :step_history
  after_commit :update_death_record_contents
  after_commit :update_death_record_metadata

  # Update death record's flat version of step contents.
  def update_death_record_contents
    self.death_record.contents = self.death_record.build_contents
    self.death_record.save!
  end

  # Update decedent metadata that we want to save directly to the record.
  def update_death_record_metadata
    meta = self.death_record.metadata
    self.death_record.name = NameHelper.pretty_name(meta[:firstName], meta[:middleName], meta[:lastName])
    self.death_record.save!
  end

  # Update an existing StepContent if it exists with the given parameters, else
  # create a new one.
  def self.update_or_create_new(*args)
    step_contents = StepContent.where(args.first.except(:contents))
    step_content = step_contents.first_or_initialize(contents: args.first[:contents].except('id'))
    step_content.update(contents: args.first[:contents].except('id'))
    step_content.death_record.save
    step_content
  end

  # Builds a hash of results, containing question titles, answers, and
  # required status. The content built by this method is useful when
  # rendering step review snippets.
  def build_results
    results = []
    step.fields.each do |key, values|
      # Grab the human readable template string, and the title of the field.
      humanReadableTemplate = values['humanReadable']
      humanReadable = values['humanReadable']
      title = values['title']

      # Determine if this field is required.
      required = values.key?('required') ? values['required'] : false

      # Grab properties of the field, and build human readable using user
      # input.
      properties = values.key?('properties') ? values['properties'] : values
      properties.each do |field_name, field|
        content = contents.dig(key, field_name)
        content = '' if content.nil?
        # We need to handle cases where the contents are more complicated, as
        # in the case of a NightMultiSelect.
        if content.is_a?(Hash)
          multi_content = []
          # Grab the radio/checkbox selections
          option = content['option'].present? ? [content['option']] : []
          begin
            specify = content['specify'].present? ? JSON.parse(content['specify']) : []
          rescue
            specify = []
          end
          # Grab the (potential) text inputs for radio/checkbox selections
          specifyInputs = content['specifyInputs'].present? ? JSON.parse(content['specifyInputs']) : {}
          (option + specify).each do |selection|
            # Construct the human readable string for this selection and any
            # of its potential free text inputs.
            input = specifyInputs.key?(selection) ? specifyInputs[selection] : ''
            input = ': ' + input if input.gsub('\n', '').present?
            multi_content.push(selection + input)
          end
          content = multi_content.join(', ')
        end
        # Only substitute the contents if the human readable needs it.
        if humanReadable.include?(field_name)
          humanReadable.gsub!(/#{'{' + field_name + '}'}/, content)
        end
      end

      # Clean humanReadable up for proper display in the front end.
      humanReadable = humanReadable.split('\n').reject{ |l| !l.gsub(/[^0-9a-z]/i, '').present? }.join('\n')
      humanReadable = humanReadable.gsub(/(^|[^0-9a-z]),/i, '')

      # Push result to array and continue.
      results.push({
        title: title,
        isRequired: required,
        requiredSatisfied: !required || (required && !humanReadable.blank?),
        humanReadable: humanReadable.split.join(' ').strip
      })
    end
    results
  end

  # Check if all 'required' fields have been satisfied for this Step.
  def required_satisfied(results)
    results.each do |result|
      return false unless result[:requiredSatisfied]
    end
    true
  end

  def as_json(options = {})
    results = build_results
    {
      id: self.id,
      name: self.step.name,
      contents: self.contents,
      editor: self.editor.as_json(options),
      results: results,
      requiredSatisfied: self.required_satisfied(results)
    }
  end
end
