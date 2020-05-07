// NightRadioSelect; custom field that asks a user to select one choice among
// many.
class NightRadioSelect extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.formData;
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
      <fieldset className="mt-3 mb-4 pt-1 pb-3 form-group" id={this.props.name + 'field'}>
        <legend>
          {this.props.schema.required && <i className="fas fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <div className="row mt-1 mb-1">
          <div className="col-md-12">
            {this.props.schema.properties[this.props.name].options.map(item =>
              <div key={'div' + item} className="form-check">
                <label key={'label' + item} className="form-check-label">
                  <input
                    key={'input' + item}
                    name={this.props.name}
                    type="radio"
                    className="form-check-input"
                    value={item}
                    onChange={this.onChange(this.props.name)}
                    checked={this.state[this.props.name] == item}
                  />
                  <span className="ml-1" key={'span' + item}>
                    {item}
                  </span>
                  {false && <input className="ml-2 col-md-4" />}
                </label>
              </div>
            )}
          </div>
        </div>
      </fieldset>
    );
  }
}
