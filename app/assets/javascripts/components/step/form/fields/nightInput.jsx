// NightInput; custom field that asks for a text string.
class NightInput extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
    this.state[this.props.name] = this.props.formData[this.props.name]
      ? this.props.formData[this.props.name]
      : '';
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
      <fieldset className="pt-1 pb-2">
        <legend>
          {this.props.schema.required &&
            <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-6">
            <input
              className="form-control"
              type="string"
              value={this.state[this.props.name]}
              onChange={this.onChange(this.props.name)}
            />
          </div>
        </div>
      </fieldset>
    );
  }
}
