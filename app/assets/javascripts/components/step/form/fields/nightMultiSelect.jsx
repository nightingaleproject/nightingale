// NightMultiSelect; shows a list of radio selections (only one can be selected
// at a time). Selecting a radio button can optionally render a list of
// checkbox options below, allowing the user to more specifically specify their
// choice.
class NightMultiSelect extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.formData;
    this.state[this.props.name] = {
      option: this.state[this.props.name].option ? this.state[this.props.name].option : null,
      specify: this.state[this.props.name].specify ? this.state[this.props.name].specify : '[]',
      specifyArr: this.state[this.props.name].specify ? JSON.parse(this.state[this.props.name].specify) : [],
      specifyInputs: this.state[this.props.name].specifyInputs ? this.state[this.props.name].specifyInputs : '{}',
      specifyInputsObj: this.state[this.props.name].specifyInputs
        ? JSON.parse(this.state[this.props.name].specifyInputs)
        : {}
    };
    this.state.visible = this.toggleShow(this.state[this.props.name]['option']);
    this.onChange = this.onChange.bind(this);
    this.onSpecifyChange = this.onSpecifyChange.bind(this);
    this.onSpecifyInputChange = this.onSpecifyInputChange.bind(this);
    this.toggleShow = this.toggleShow.bind(this);
    this.renderRadio = this.renderRadio.bind(this);
  }

  onChange(event) {
    state = { ...this.state };
    state[this.props.name].option = event.currentTarget.value;
    state[this.props.name].specify = '';
    state[this.props.name].specifyArr = [];
    state['visible'] = this.toggleShow(event.currentTarget.value);
    this.setState(state, () => this.props.onChange(this.state));
  }

  onSpecifyChange(event) {
    name = event.currentTarget.value;
    state = { ...this.state };
    specifyArr = state[this.props.name]['specifyArr'];
    if (_.indexOf(specifyArr, name) >= 0) {
      // Remove if already in
      specifyArr = _.without(specifyArr, name);
    } else {
      // Add if not in
      specifyArr = _.union(specifyArr, [name]);
    }
    state[this.props.name]['specifyArr'] = specifyArr;
    state[this.props.name]['specify'] = JSON.stringify(specifyArr);
    this.setState(state, () => this.props.onChange(this.state));
  }

  onSpecifyInputChange(event) {
    name = event.currentTarget.value;
    state = { ...this.state };
    specifyInputsObj = state[this.props.name]['specifyInputsObj'];
    specifyInputsObj[event.currentTarget.name] = event.currentTarget.value;
    state[this.props.name]['specifyInputsObj'] = specifyInputsObj;
    state[this.props.name]['specifyInputs'] = JSON.stringify(specifyInputsObj);
    this.setState(state, () => this.props.onChange(this.state));
  }

  // If a radio button was clicked that has more options, show those options.
  toggleShow(name) {
    // Find name of specify block to show
    for (var option of this.props.schema.properties[this.props.name].options) {
      if (_.isObject(option) && option.text === name) {
        var show = option.show;
        break;
      }
    }
    visible = { ...this.state.visible };
    visible = _.mapValues(visible, () => false);
    if (show) {
      visible[show] = true;
    }
    return visible;
  }

  // Render a radio button option.
  renderRadio(item) {
    var text = _.isObject(item) ? item['text'] : item;
    var show = _.isObject(item) ? item['show'] : null;
    var input = _.isObject(item) ? item['input'] : false;
    return (
      <div key={'div' + text} className="form-check">
        <label key={'label' + text} className="form-check-label">
          <input
            key={'input' + text}
            name={this.props.name}
            type="radio"
            className="form-check-input"
            value={text}
            onChange={this.onChange}
            checked={this.state[this.props.name]['option'] === text}
          />
          <span className="ml-1" key={'span' + text}>
            {text}
          </span>
          {input &&
            <input
              name={text}
              className="ml-4 col-md-4 night-input"
              value={this.state[this.props.name].specifyInputsObj[text]}
              onChange={this.onSpecifyInputChange}
            />}
        </label>
      </div>
    );
  }

  renderSpecify(id, options) {
    if (this.state.visible[id]) {
      return (
        <div key={id + '1'} className="row mt-3 mb-1">
          <div key={id + '2'} className="col-md-12">
            <h6 className="mb-3">Please specify:</h6>
            {options.map(item =>
              <div key={'div' + (_.isObject(item) ? item['text'] : item)} className="form-check">
                <label key={'label' + (_.isObject(item) ? item['text'] : item)} className="form-check-label">
                  <input
                    key={'input' + (_.isObject(item) ? item['text'] : item)}
                    name={this.props.name}
                    type="checkbox"
                    className="form-check-input"
                    value={_.isObject(item) ? item['text'] : item}
                    onChange={this.onSpecifyChange}
                    checked={
                      _.indexOf(this.state[this.props.name]['specifyArr'], _.isObject(item) ? item['text'] : item) >= 0
                    }
                  />
                  <span className="ml-1" key={'span' + (_.isObject(item) ? item['text'] : item)}>
                    {_.isObject(item) ? item['text'] : item}
                  </span>
                  {(_.isObject(item) ? item['input'] : false) &&
                    <input
                      name={_.isObject(item) ? item['text'] : item}
                      className="ml-4 col-md-4 night-input"
                      value={this.state[this.props.name].specifyInputsObj[_.isObject(item) ? item['text'] : item]}
                      onChange={this.onSpecifyInputChange}
                    />}
                </label>
              </div>
            )}
          </div>
        </div>
      );
    }
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
            {this.props.schema.properties[this.props.name].options.map(item => this.renderRadio(item))}
          </div>
        </div>
        {_.toPairs(this.props.schema.properties[this.props.name].specifyOptions).map(specify =>
          this.renderSpecify(specify[0], specify[1])
        )}
      </fieldset>
    );
  }
}
