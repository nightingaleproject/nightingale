// NightTextarea; custom field that asks for free text input.
class NightTextarea extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
    this.state[this.props.name] = this.props.formData[this.props.name] ? this.props.formData[this.props.name] : '';
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
          {this.props.schema.required && <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <div className="row form-group mt-1 mb-1 pl-3 pr-3 pb-3">
          <textarea
            className="form-control"
            rows="5"
            onChange={this.onChange(this.props.name)}
            value={this.state[this.props.name]}
          />
        </div>
      </fieldset>
    );
  }
}
