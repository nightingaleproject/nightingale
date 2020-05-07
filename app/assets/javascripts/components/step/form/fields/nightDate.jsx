// NightDate; custom field that asks for a date (year, month, day).
class NightDate extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.formData;
    this.state[this.props.name] = this.state[this.props.name]
      ? this.state[this.props.name]
      : moment().format('YYYY-MM-DD');
    this.onChange = this.onChange.bind(this);
    this.renderDateType = this.renderDateType.bind(this);
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

  renderDateType() {
    if (this.props.schema.showDateType) {
      return (
          <div className="form-check">
            {this.props.schema.properties.dateType.options.map(item =>
              <label key={'label' + item} className="row mt-1 ml-1 form-check-label">
                <input
                  key={'input' + item}
                  name="dateType"
                  type="radio"
                  className="form-check-input"
                  value={item}
                  onChange={this.onChange('dateType')}
                  checked={this.state.dateType == item}
                />
                <span className="ml-1" key={'span' + item}>
                  {item}
                </span>
              </label>
            )}
          </div>
      );
    }
  }

  render() {
    return (
      <fieldset className="pt-1 pb-2" id={this.props.name + 'field'}>
        <legend>
          {this.props.schema.required && <i className="fas fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <div className="form-group row">
          <div className="col-5">
            <input
              className="form-control"
              type="date"
              value={this.state[this.props.name]}
              onChange={this.onChange(this.props.name)}
              id={this.props.name + 'input'}
            />
          </div>
        </div>
        {this.renderDateType()}
      </fieldset>
    );
  }
}
