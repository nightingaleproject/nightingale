// Form component; makes up the editable portion of the visible step.
class Form extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
    this.onChange = this.onChange.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    this.setState(nextProps);
  }

  onChange(state) {
    var currentState = { ...this.state };
    currentState.deathRecord.stepStatus.currentStep.contents.contents =
      state.formData;
    // Update metadata if we are on the Identity step
    if (currentState.deathRecord.stepStatus.currentStep.name == 'Identity') {
      currentState.deathRecord.metadata = this.rebuildMetadata(state.formData);
    }
    this.setState(currentState, () => this.state.onChange(this.state));
  }

  // Rebuild metadata from formData. This function should only be used when
  // the form is currently on the identity step.
  rebuildMetadata(formData) {
    metadata = {};
    if (formData.decedentName) {
      metadata['firstName'] = formData.decedentName['firstName'];
      metadata['middleName'] = formData.decedentName['middleName'];
      metadata['lastName'] = formData.decedentName['lastName'];
      metadata['suffix'] = formData.decedentName['suffix'];
    }
    if (formData.ssn) {
      metadata['ssn1'] = formData.ssn['ssn1'];
      metadata['ssn2'] = formData.ssn['ssn2'];
      metadata['ssn3'] = formData.ssn['ssn3'];
    }
    return metadata;
  }

  render() {
    // Custom field types for step forms
    const fields = {
      nightName: NightName,
      nightInput: NightInput,
      nightSSN: NightSSN,
      nightFullAddress: NightFullAddress,
      nightShortAddress: NightShortAddress,
      nightRadioSelect: NightRadioSelect,
      nightMultiSelect: NightMultiSelect,
      nightTextarea: NightTextarea,
      nightDate: NightDate,
      nightTime: NightTime,
      nightCOD: NightCOD
    };
    var prev =
      this.state.deathRecord.stepStatus.previousStep &&
      this.state.deathRecord.stepStatus.previousStep.editable;
    var contents = this.state.deathRecord.stepStatus.currentStep.contents
      .contents;
    return (
      <div className="mb-4">
        <div className="row">
          <JSONSchemaForm.default
            schema={this.state.deathRecord.stepStatus.currentStep.jsonschema}
            uiSchema={this.state.deathRecord.stepStatus.currentStep.uischema}
            formData={contents}
            fields={fields}
            onSubmit={this.props.onSave}
            onChange={this.onChange}
            noValidate={true}
          >
            <div className="pull-right mt-1">
              <a
                href={Routes.death_records_path()}
                className="btn btn-secondary mr-2"
              >
                Cancel
              </a>
              <button type="submit" className="btn btn-primary">
                Save and Continue
              </button>
            </div>
          </JSONSchemaForm.default>
        </div>
      </div>
    );
  }
}
