// NightShortAddress; custom widget that asks for a short address (country
// state, and city). Optionally can ask for the name of the facility located at
// the address. Makes use of structured data as returned by the backend.
class NightShortAddress extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      name: this.props.formData.name ? this.props.formData.name : '',
      country: this.props.formData.country ? this.props.formData.country : '',
      state: this.props.formData.state ? this.props.formData.state : '',
      city: this.props.formData.city ? this.props.formData.city : ''
    };
    this.state.options = {
      country: [],
      state: [],
      city: []
    };
    this.updateState = this.updateState.bind(this);
    this.onChange = this.onChange.bind(this);
    this.disabled = this.disabled.bind(this);
    this.getGeoData = this.getGeoData.bind(this);
    this.clearSubsequent = this.clearSubsequent.bind(this);
    this.buildDatalist = this.buildDatalist.bind(this);
  }

  // After first render, make sure we backfill geography data!
  componentDidMount() {
    this.getGeoData(false);
  }

  onChange(name) {
    return event => {
      this.setState(
        {
          [name]: event.target.value ? event.target.value : ''
        },
        () => this.updateState(name)
      );
    };
  }

  // Reset fields further in the heirarchy; Fill newly enabled fields with
  // options; Update parent states.
  updateState(name) {
    this.clearSubsequent(name);
    this.props.onChange(this.state);
  }

  // Given a state (current country, state, city), ask the server to
  // fill in the blanks.
  getGeoData(next) {
    // Only grab geographic data if the select country is the USA.
    if (!this.state.country || this.state.country != 'United States') {
      return;
    }
    var state = {
      next: next,
      country: this.state.country,
      state: this.state.state,
      city: this.state.city
    };
    $.ajax({
      url: Routes.geography_short_path(),
      dataType: 'json',
      contentType: 'application/json',
      type: 'POST',
      data: JSON.stringify(state),
      success: function(options) {
        if (Object.keys(options).length == 1) {
          // We are only updating a single select.
          ops = { ...this.state.options };
          ops[Object.keys(options)[0]] = options[Object.keys(options)[0]];
          this.setState({ options: ops });
        } else {
          // We are updating all selects.
          this.setState({ options: options });
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(Routes.geography_short_path(), status, err.toString());
      }.bind(this)
    });
  }

  // Given the name of one of the address inputs, determine if it should be
  // disabled.
  disabled(name) {
    switch (name) {
      case 'country':
        return false;
        break;
      case 'state':
        return this.state.country ? false : true;
        break;
      case 'city':
        return this.state.country && this.state.state ? false : true;
        break;
    }
  }

  // If the user changes a value higher in the hierarchy, be sure to clear
  // subsequent fields. After resetting the proper fields, ask the server to
  // fill in the details for the most specific dropdown still active.
  clearSubsequent(name) {
    var options = { ...this.state.options };
    switch (name) {
      case 'country':
        options['state'] = [];
        options['city'] = [];
        this.setState(
          {
            state: '',
            city: '',
            options: options
          },
          () => this.getGeoData(true)
        );
        break;
      case 'state':
        options['city'] = [];
        this.setState(
          {
            city: '',
            options: options
          },
          () => this.getGeoData(true)
        );
        break;
    }
  }

  buildDatalist(options, name) {
    // Check if IE 9 or earlier
    if (document.documentMode <= 9) {
      var ieOpen = <select data-datalist={this.props.name + name}>; var ieClose = </select>;
    } else {
      var ieOpen = '';
      var ieClose = '';
    }
    return (
      <datalist id={this.props.name + name} key={this.props.name + name}>
        {ieOpen}
        {options.map(option =>
          <option key={this.props.name + name + option}>
            {option}
          </option>
        )}
        {ieClose}
      </datalist>
    );
  }

  render() {
    return (
      <fieldset className="mt-4 pb-4">
        <legend>
          {this.props.schema.required && <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        {this.props.schema.named &&
          <div className="row mt-1 mb-4">
            <div className="col-md-12">
              <label htmlFor="name">Name</label>
              <input
                className="form-control"
                id="name"
                type="string"
                value={this.state.name}
                onChange={this.onChange('name')}
              />
            </div>
          </div>}
        <div className="row mt-1">
          <div className="col-md-4">
            <label htmlFor="county">Country</label>
            <input
              type="text"
              list={this.props.name + 'country'}
              className="form-control"
              value={this.state.country}
              onChange={this.onChange('country')}
              disabled={this.disabled('country')}
            />
            {this.buildDatalist(['United States', 'Canada', 'Mexico'], 'country')}
          </div>
          <div className="col-md-4">
            <label htmlFor="state">State/Territory/Province</label>
            <input
              type="text"
              list={this.props.name + 'state'}
              className="form-control"
              value={this.state.state}
              onChange={this.onChange('state')}
              disabled={this.disabled('state')}
            />
            {this.buildDatalist(this.state.options.state, 'state')}
          </div>
          <div className="col-md-4">
            <label htmlFor="city">City</label>
            <input
              type="text"
              list={this.props.name + 'city'}
              className="form-control"
              value={this.state.city}
              onChange={this.onChange('city')}
              disabled={this.disabled('city')}
            />
            {this.buildDatalist(this.state.options.city, 'city')}
          </div>
        </div>
      </fieldset>
    );
  }
}
