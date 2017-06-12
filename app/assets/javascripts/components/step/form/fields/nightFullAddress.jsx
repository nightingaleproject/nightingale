// NightFullAddress; custom widget that asks for a full address (state, county,
// city, zipcode, street, and apt/suite/unit designation). Optionally can ask
// for the name of the facility located at the address. Makes use of structured
// data as returned by the backend.
class NightFullAddress extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      name: this.props.formData.name ? this.props.formData.name : '',
      state: this.props.formData.state ? this.props.formData.state : '',
      county: this.props.formData.county ? this.props.formData.county : '',
      city: this.props.formData.city ? this.props.formData.city : '',
      zip: this.props.formData.zip ? this.props.formData.zip : '',
      street: this.props.formData.street ? this.props.formData.street : '',
      apt: this.props.formData.apt ? this.props.formData.apt : ''
    };
    this.state.options = {
      state: [],
      county: [],
      city: [],
      zip: []
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

  // Given a state (current state, county, city, zip), ask the server to
  // fill in the blanks.
  getGeoData(next) {
    var state = {
      next: next,
      state: this.state.state,
      county: this.state.county,
      city: this.state.city,
      zip: this.state.zip
    };
    $.ajax({
      url: Routes.geography_full_path(),
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
        console.error(Routes.geography_full_path(), status, err.toString());
      }.bind(this)
    });
  }

  // Given the name of one of the address inputs, determine if it should be
  // disabled.
  disabled(name) {
    switch (name) {
      case 'state':
        return false;
        break;
      case 'county':
        return this.state.state ? false : true;
        break;
      case 'city':
        return this.state.state && this.state.county ? false : true;
        break;
      case 'zip':
        return this.state.state && this.state.county && this.state.city
          ? false
          : true;
        break;
    }
  }

  // If the user changes a value higher in the hierarchy, be sure to clear
  // subsequent fields. After resetting the proper fields, ask the server to
  // fill in the details for the most specific dropdown still active.
  clearSubsequent(name) {
    var options = { ...this.state.options };
    switch (name) {
      case 'state':
        options['city'] = [];
        options['zip'] = [];
        this.setState(
          {
            county: '',
            city: '',
            zip: '',
            options: options
          },
          () => this.getGeoData(true)
        );
        break;
      case 'county':
        options['city'] = [];
        options['zip'] = [];
        this.setState(
          {
            city: '',
            zip: '',
            options: options
          },
          () => this.getGeoData(true)
        );
        break;
      case 'city':
        options['zip'] = [];
        this.setState(
          {
            zip: '',
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
      var ieOpen = (
        <select data-datalist={this.props.name + name}>
          ;
          var ieClose ={' '}
        </select>
      );
    } else {
      var ieOpen = '';
      var ieClose = '';
    }
    return (
      <datalist id={this.props.name + name}>
        {ieOpen}
        {options.map(option => <option key={option + name}>{option}</option>)}
        {ieClose}
      </datalist>
    );
  }

  render() {
    return (
      <fieldset className="mt-4 pt-1 pb-2">
        <legend>
          {this.props.schema.required &&
            <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
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
                onChange={this.onChange('name', false)}
              />
            </div>
          </div>}
        <div className="row mt-1">
          <div className="col-md-4">
            <label htmlFor={this.props.name + 'state'}>
              State or Territory
            </label>
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
            <label htmlFor={this.props.name + 'county'}>County</label>
            <input
              type="text"
              list={this.props.name + 'county'}
              className="form-control"
              value={this.state.county}
              onChange={this.onChange('county')}
              disabled={this.disabled('county')}
            />
            {this.buildDatalist(this.state.options.county, 'county')}
          </div>
          <div className="col-md-4">
            <label htmlFor={this.props.name + 'city'}>City</label>
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
        <div className="row mt-4">
          <div className="col-md-3">
            <label htmlFor={this.props.name + 'zip'}>ZIP Code</label>
            <input
              type="text"
              list={this.props.name + 'zip'}
              className="form-control"
              value={this.state.zip}
              onChange={this.onChange('zip')}
              disabled={this.disabled('zip')}
            />
            {this.buildDatalist(this.state.options.zip, 'zip')}
          </div>
        </div>
        <div className="row mt-4 mb-4">
          <div className="col16-md-12">
            <label htmlFor="street">Street Address</label>
            <input
              className="form-control"
              id="street"
              type="string"
              value={this.state.street}
              onChange={this.onChange('street')}
            />
          </div>
          <div className="col16-md-4">
            <label htmlFor="apt">Apt/Suite/Unit</label>
            <input
              className="form-control"
              id="apt"
              type="string"
              value={this.state.apt}
              onChange={this.onChange('apt')}
            />
          </div>
        </div>
      </fieldset>
    );
  }
}
