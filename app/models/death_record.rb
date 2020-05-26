class DeathRecord < ApplicationRecord
  audited
  belongs_to :workflow
  belongs_to :owner, class_name: 'User'
  belongs_to :creator, class_name: 'User'
  belongs_to :step_flow
  has_one :step_status
  has_many :step_contents
  has_many :step_histories
  has_many :comments
  has_one :user_token
  has_one :registration
  has_many :death_certificates

  # Return the StepFlows (in order) that make up this Workflow.
  def step_flows
    self.workflow.step_flows
  end

  # Builds a flat representation of this death records contents.
  def build_contents
    # Merge the array of hashes into one.
    flatten_hash = Hash[*step_contents.collect(&:contents).collect{|h| h.to_a}.flatten]
    # Create a flat hash structure
    Hash.to_dotted_hash flatten_hash
  end

  # Given a dot notation flat hash, this will break out the flat hash into the correct "steps"
  # Returns a hash of steps and the parameters that match the step's schema.
  def separate_step_contents(flat_hash)
    step_contents_hash = {}
    nested_hash = Hash.to_nested_hash flat_hash
    self.steps.each do |step|
      values = nested_hash.slice(*get_params_for_step(step))
      step_contents_hash[step.name] = values unless values.empty?
    end
    step_contents_hash
  end

  # Return the Steps (in order) that make up this Workflow.
  def steps
    step_flows.collect(&:current_step)
  end

  # Updates the current record values given a hash of LOINC codes to values. The record
  # will be updated according to how the given codes align to how the current schema was
  # defined when this record was created. For example:
  #
  # Given:
  # {
  #   '45392-8': 'John', # LOINC code for patient forename
  #   '45394-4': 'Smith' # LOINC code for patient surname
  # }
  #
  # The record will be updated to set the proper fields as defined in the schema. So the
  # field where '45392-8' was defined (in the example workflows, this is in the
  # identity step), the corresponding given value will be made that value.
  #
  # Note: existing values will be overwritten; values given that have no place in the
  # schema will be ignored.
  def update_from_loinc(values)
    paths = loinc_paths(jsonschemas)
    structured_values = {}
    values.each do |key, value|
      # Check if this LOINC value has a normative answer list, if so convert
      structured_values[paths[key]['path']] = if paths[key]['values']
                                        paths[key]['values'].key(value)
                                      else
                                        value
                                      end
    end
    seperated = separate_step_contents(structured_values)
    self.steps.each do |step|
      if seperated[step.name]
        StepContent.update_or_create_new(death_record: self,
                                         step: step,
                                         contents: seperated[step.name],
                                         editor: self.owner) # TODO: This probably needs to change!
      end
    end
  end

  # Converts the record contents to a hash of LOINC codes to values. An example result
  # might look like:
  #
  # {
  #   '45392-8': 'John', # LOINC code for patient forename
  #   '45394-4': 'Smith' # LOINC code for patient surname
  # }
  def to_loinc
    flat_contents = build_contents
    loinc_contents = {}
    # Loop over each value in the record
    flat_contents.each do |value_path, value|
      current = {}
      current['properties'] = jsonschemas
      # Dive into the JSON Schema for this value to find the most nested portion
      value_path.split('.').each do |path_step|
        current = current['properties'][path_step]
      end
      # Set the corresponding LOINC code to equal the proper value representation
      if current['loinc'] && current['loinc']['values']
        # This LOINC code has normative answers
        loinc_contents[current['loinc']['code']] = current['loinc']['values'][value]
      elsif current['loinc'] && current['loinc']['index']
        # Multiple values for a single loinc code (probably cause of death and
        # onset to death fields)
        loinc_contents[current['loinc']['code']] = {} unless loinc_contents[current['loinc']['code']]
        loinc_contents[current['loinc']['code']][current['loinc']['index']] = value
      elsif current['loinc']
        # This LOINC code does NOT have normative answers
        loinc_contents[current['loinc']['code']] = value
      end
    end
    return loinc_contents.stringify_keys
  end

  # Returns a hash of all allowed params for this DeathRecord.
  def whitelist
    steps.collect(&:whitelist).flatten.reduce({}, :merge)
  end

  # Determines if this DeathRecord can increment its current Step.
  def can_increment_step
    !step_flow.next_step.nil?
  end

  # Returns the next Step in this DeathRecords workflow.
  def next_step
    self.step_flow.next_step if can_increment_step
  end

  # Return the combination of this records step jsonschemas
  def jsonschemas
    schemas = {}
    steps.collect(&:jsonschema).each do |s|
      schemas.merge!(s['properties']) unless s.nil?
    end
    return schemas.stringify_keys
  end

  # Recursively builds a hash describing the paths (in dot notation) and their
  # corresponding loinc codes. For example: {'45392-8': 'decedentName.firstName'}
  def loinc_paths(schema, current_path='', paths={})
    schema.keys.each do |k|
      nested_schema = schema[k]
      if nested_schema['loinc']
        paths[nested_schema['loinc']['code']] = {path: (current_path + '.' + k).rchomp('.').chomp('.'), values: nested_schema['loinc']['values']}.stringify_keys
      end
      if nested_schema['properties']
        loinc_paths(nested_schema['properties'], current_path + '.' + k, paths)
      end
    end
    return paths.stringify_keys
  end

  # Move this DeathRecord one step forward in its Workflow.
  def increment_step
    if self.step_status.current_step == self.step_flow.current_step
      # We are incrementing withing the context of the normal workflow.
      self.step_flow = self.step_flow.next if can_increment_step
      self.step_status.mirror_step_flow(step_flow)
    else
      # We are in the middle of a workflow jump; instead of incrementing
      # to the next StepFlow, we need to reset the state of the StepStatus
      # to where the DeathRecord was before the workflow jump. We also need
      # to restore ownership to the User who requested the change.
      self.step_status.mirror_step_flow(step_flow)
      unless self.step_status.requestor.nil?
        self.owner = self.step_status.requestor # Set owner back to requestor
        self.step_status.requestor = nil # Blank out requestor
      end
    end
    self.step_status.save
    self.save
  end

  # Determines if this DeathRecord can derement its current Step.
  def can_decrement_step
    !step_flow.previous_step.nil?
  end

  # Returns the previous Step in this DeathRecords workflow.
  def previous_step
    self.step_flow.previous_step if can_decrement_step
  end

  # Move this DeathRecord one step backward in its Workflow.
  def decrement_step
    self.step_flow = self.step_flow.prev if can_decrement_step
    self.step_status.mirror_step_flow(self.step_flow)
    self.step_status.save
    self.save
  end

  # Move this DeathRecord to an arbitrary Step in its Workflow by modifying
  # its StepStatus. If linear is true, the DeathRecord's StepStatus will
  # mirror the StepFlow that contains the given step (meaning the
  # will progress normally). If linear is false, only the current_step of
  # the StepStatus is changed, meaning the next time increment_step is called,
  # the DeathRecord will return back to where it was previously. The latter
  # case is particularly useful when, for example, a physician requests edits
  # from a funeral director, and wants the record to return to them after
  # the funeral director makes the requested edits.
  def update_step(step, linear)
    if linear
      self.step_flow = step_flows.find_by(current_step: step)
      self.step_status.mirror_step_flow(self.step_flow)
      self.save
    else
      self.step_status.current_step = step
    end
    self.step_status.save
    self.save
  end

  # Sets the DeathRecord to the given step, and sets the owner to the user
  # who edited or should have edited that step.
  def reassign(step, user)
    # Determine the proper user who should be making the edits
    step_flow = step_flows.find_by(current_step: step)
    target_role = step_flow.current_step_role

    # Update the record
    current_step_role
  end

  # Change ownership of this DeathRecord.
  def update_owner(user)
    self.notify = true if self.owner != user
    self.owner = user unless user.nil?
    self.save
  end

  # Returns an array of Steps that are editable by the given user for this
  # DeathRecord.
  def steps_editable(user)
    # TODO: Improve efficiency! Way too many DB calls!
    self.workflow.step_flows.where(current_step_role: user.roles.first.name).collect(&:current_step)
  end

  # Check if the given user can edit the given step in the context of this
  # DeathRecord.
  def step_editable?(user, step)
    # TODO: Improve efficiency! Way too many DB calls!
    steps_editable(user).collect(&:name).include? step.name
  end

  # Get the Step that matches the given name, within the context of
  # this DeathRecords Workflow (and is editable by the current owner).
  def editable_step_by_name(user, step_name)
    steps_editable(user).detect{ |step| step.name == step_name }
  end

  # Returns a hash of some simple metadata describing the decedent.
  def metadata
    identity_step = steps.detect{ |step| step.name == 'Identity' }
    if identity_step.step_content(self) && identity_step.step_content(self).key?('decedentName')
      decedentName = identity_step.step_content(self)['decedentName']
    end
    if identity_step.step_content(self) && identity_step.step_content(self).key?('ssn')
      ssn = identity_step.step_content(self)['ssn']
    end
    {
      firstName: decedentName.nil? ? '' : decedentName['firstName'],
      middleName: decedentName.nil? ? '' : decedentName['middleName'],
      lastName: decedentName.nil? ? '' : decedentName['lastName'],
      suffix: decedentName.nil? ? '' : decedentName['suffix'],
      ssn1: ssn.nil? ? '' : ssn['ssn1'],
      ssn2: ssn.nil? ? '' : ssn['ssn2'],
      ssn3: ssn.nil? ? '' : ssn['ssn3']
    }
  end

  def as_json(options = {})
    options.merge!({death_record: self})
    # Only load the things we will need.
    next_step_flow = self.workflow.step_flows.includes(:current_step).find_by(current_step: self.step_status.current_step)
    next_step_role = next_step_flow.send_to_role
    next_step_role_pretty = next_step_role.titleize if next_step_role
    steps = []
    self.workflow.steps.each do |step|
      steps.push(step.as_json(options))
    end
    {
      id: self.id,
      owner: self.owner.as_json(options),
      creator: self.creator.as_json(options),
      comments: self.comments.as_json(options),
      stepStatus: self.step_status.as_json(options),
      nextStepRole: next_step_role,
      nextStepRolePretty: next_step_role_pretty,
      steps: steps,
      metadata: metadata,
      lastUpdatedAt: self.updated_at,
      registration: self.registration.as_json(options),
      notify: self.notify
    }
  end

  # Grabs the keys for the given step's jsonSchema
  def get_params_for_step(step)
    if step['jsonschema'].present? && step['jsonschema']['properties'].present?
      return step['jsonschema']['properties'].keys
    end
    return []
  end

  # Generate printable versions of a death certificate for this record and store locally
  def generate_certificate(user)
    # We want to generate a pdf with the death record data with formatting.
    document = FormatPDF.generate_formatted_pdf(self.build_contents)
    template_pdf = CombinePDF.load(Rails.root + "2003-death-certificate.pdf")
    record_pdf = CombinePDF.parse(document)
    # Overlay the generated pdf with data over the template pdf.
    template_pdf.pages.each_with_index do |page, index|
      page << record_pdf.pages[index] if record_pdf.pages[index]
    end

    death_certificate = DeathCertificate.create(death_record: self, document: template_pdf.to_pdf, metadata: self.metadata, creator: user)
  end

  # Grabs the most recent created Death Certificate
  def newest_certificate
    self.death_certificates.where('created_at is NOT NULL').order('created_at DESC').first
  end
end

# Adds functions to the Hash class.
class Hash
 # Function creates a flat hash structure by using "." in the keys to represent nesting.
 def self.to_dotted_hash(hash, recursive_key = "")
    hash.each_with_object({}) do |(k, v), ret|
      key = recursive_key + k.to_s
      if v.is_a? Hash
        ret.merge! to_dotted_hash(v, key + ".")
      else
        ret[key] = v
      end
    end
  end

  # Function creates a nested hash from a flat hash with "." notation.
  def self.to_nested_hash(hash)
    hash.each_with_object({}) do |(key, value), all|
      key_parts = key.split('.').map!(&:to_s)
      leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
      leaf[key_parts.last] = value
    end
  end
end

# Adds a function to the String class.
class String
  def rchomp(sep = $/)
    self.start_with?(sep) ? self[sep.size..-1] : self
  end
end
