// NightName; custom field that asks for a legal name (first, middle, last,
// suffix). Also includes the optional ability to enter up to five pseudonyms.
class NightName extends React.Component {
  constructor(props) {
    super(props);
    // Show akas?
    if (this.props.schema.showAkas) {
      if (!this.props.formData.akas) {
        // Create a blank aka to start with if there are none.
        this.props.formData.akas = [
          {
            firstName: '',
            middleName: '',
            lastName: '',
            suffix: ''
          }
        ];
      }
      if (this.props.formData.akas.length >= 5) {
        this.props.formData.addAkas = false;
      } else {
        this.props.formData.addAkas = true;
      }
    }
    this.state = this.props.formData;
    this.onChange = this.onChange.bind(this);
    this.onAkaChange = this.onAkaChange.bind(this);
    this.onAddClick = this.onAddClick.bind(this);
  }

  onChange(state) {
    this.setState(state, () => this.props.onChange(this.state));
  }

  onAkaChange(index, state) {
    akas = [...this.state.akas];
    akas[index] = state;
    this.setState({ akas: akas }, () => this.props.onChange(this.state));
  }

  onAddClick(event) {
    event.preventDefault();
    // Limit number of added aka fields to 5.
    if (!this.props.schema.showAkas || !this.state.addAkas) {
      return;
    }
    akas = [...this.state.akas];
    akas.push({
      firstName: '',
      middleName: '',
      lastName: '',
      suffix: ''
    });
    this.setState({ akas: akas }, () => this.props.onChange(this.state));
    if (akas.length >= 5) {
      this.setState({ addAkas: false });
    }
  }

  render() {
    return (
      <fieldset className="pt-1 pb-2">
        <legend>
          {this.props.schema.required && <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <Name
          key={this.props.schema.title + 'name'}
          onChange={this.onChange}
          showMaiden={this.props.schema.showMaiden}
          formData={this.state}
        />
        {this.props.schema.showAkas &&
          <div>
            <h5 className="mt-3 mb-3">Alternative Names (AKAs)</h5>
            {this.state.akas.map((aka, index) =>
              <Name key={'aka' + index} onChange={e => this.onAkaChange(index, e)} formData={aka} />
            )}
            <div className="row pull-right pr-3 pb-3 pt-2">
              <button
                type="button"
                className="btn btn-primary"
                onClick={this.onAddClick}
                disabled={!this.state.addAkas}
              >
                <i className="fa fa-plus" /> Add More
              </button>
            </div>
          </div>}
      </fieldset>
    );
  }
}
