// NightSSN; custom field that asks for a Social Security Number.
class NightSSN extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      ssn1: this.props.formData.ssn1 ? this.props.formData.ssn1 : '',
      ssn2: this.props.formData.ssn2 ? this.props.formData.ssn2 : '',
      ssn3: this.props.formData.ssn3 ? this.props.formData.ssn3 : ''
    };
    this.onChange = this.onChange.bind(this);
  }

  onChange(name) {
    return event => {
      this.setState(
        {
          [name]: event.target.value
        },
        () => this.props.onChange(this.state)
      );
    };
  }

  render() {
    return (
      <fieldset className="mt-4 pt-1 pb-2">
        <legend>
          {this.props.schema.required &&
            <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <div className="row mt-1 mb-1">
          <div className="form-group col32-md-5">
            <input
              className="form-control"
              type="string"
              maxLength="3"
              value={this.state.ssn1}
              onChange={this.onChange('ssn1')}
            />
          </div>
          <span className="night-ssn-divider">-</span>
          <div className="form-group col32-md-4">
            <input
              className="form-control"
              type="string"
              maxLength="2"
              value={this.state.ssn2}
              onChange={this.onChange('ssn2')}
            />
          </div>
          <span className="night-ssn-divider">-</span>
          <div className="form-group col32-md-6">
            <input
              className="form-control"
              type="string"
              maxLength="4"
              value={this.state.ssn3}
              onChange={this.onChange('ssn3')}
            />
          </div>
        </div>
      </fieldset>
    );
  }
}
