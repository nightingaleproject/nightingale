// Name; custom widget used to ask a name (first, middle, last, suffix).
class Name extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.formData;
    this.state = {
      firstName: this.props.formData.firstName
        ? this.props.formData.firstName
        : '',
      middleName: this.props.formData.middleName
        ? this.props.formData.middleName
        : '',
      lastName: this.props.formData.lastName
        ? this.props.formData.lastName
        : '',
      suffix: this.props.formData.suffix ? this.props.formData.suffix : ''
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
      <div className="row">
        <div className="form-group col16-md-5">
          <label htmlFor="first">First Name</label>
          <input
            className="form-control"
            type="text"
            id="first"
            value={this.state.firstName}
            onChange={this.onChange('firstName')}
          />
        </div>
        <div className="form-group col16-md-4">
          <label htmlFor="middle">Middle Name</label>
          <input
            className="form-control"
            type="text"
            id="middle"
            value={this.state.middleName}
            onChange={this.onChange('middleName')}
          />
        </div>
        <div className="form-group col16-md-5">
          {this.props.showMaiden && <label htmlFor="last">Maiden Name</label>}
          {!this.props.showMaiden && <label htmlFor="last">Last Name</label>}
          <input
            className="form-control"
            type="text"
            id="last"
            value={this.state.lastName}
            onChange={this.onChange('lastName')}
          />
        </div>
        <div className="form-group col16-md-2">
          <label htmlFor="suffix">Suffix</label>
          <input
            className="form-control"
            type="text"
            id="suffix"
            value={this.state.suffix}
            onChange={this.onChange('suffix')}
          />
        </div>
      </div>
    );
  }
}
