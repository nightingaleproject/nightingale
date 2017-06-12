// NightTime; custom field that asks for a time.
class NightTime extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.formData;
    this.state[this.props.name] = this.state[this.props.name]
      ? this.state[this.props.name]
      : moment().format('HH:mm');
    this.onChange = this.onChange.bind(this);
    this.renderTimeType = this.renderTimeType.bind(this);
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

  renderTimeType() {
    if (this.props.schema.showTimeType) {
      return (
        <div className="form-group">
          {this.props.schema.properties.timeType.options.map(item =>
            <label
              key={'label' + item}
              className="row mt-1 ml-1 form-check-label"
            >
              <input
                key={'input' + item}
                name="timeType"
                type="radio"
                className="form-check-input"
                value={item}
                onChange={this.onChange('timeType')}
                checked={this.state.timeType == item}
              />
              <span className="ml-1" key={'span' + item}>{item}</span>
            </label>
          )}
        </div>
      );
    }
  }

  render() {
    return (
      <fieldset className="pt-1 pb-2">
        <legend>
          {this.props.schema.required &&
            <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <div className="form-group row">
          <div className="col-5">
            <input
              className="form-control"
              type="time"
              value={this.state[this.props.name]}
              onChange={this.onChange(this.props.name)}
            />
          </div>
        </div>
        {this.renderTimeType()}
      </fieldset>
    );
  }
}
