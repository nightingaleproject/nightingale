// Decedent component; shows a quick summary of the decent (name, ssn).
class Decedent extends React.Component {
  constructor(props) {
    super(props);
  }

  // Returns a header containing the decedent's name (if applicable), and
  // the decedent's ssn (if applicable).
  decedentInfo() {
    if (this.decedentName() || this.decedentSsn()) {
      return (
        <div className="pb-2">{this.decedentName()}{this.decedentSsn()}</div>
      );
    }
  }

  // Return a styled version of the decedent's name, constructed by what
  // information is available.
  decedentName() {
    var metadata = this.props.deathRecord.metadata;
    // Format name
    if (metadata.firstName && metadata.lastName && metadata.middleName) {
      return (
        <h5 className="card-text">
          {metadata.lastName}, {metadata.firstName} {metadata.middleName[0]}.
          {' '}{metadata.suffix}
        </h5>
      );
    } else if (metadata.firstName && metadata.middleName) {
      return (
        <h5 className="card-text">
          {metadata.firstName} {metadata.middleName[0]}. {metadata.suffix}
        </h5>
      );
    } else if (metadata.firstName && metadata.lastName) {
      return (
        <h5 className="card-text">
          {metadata.lastName}, {metadata.firstName} {metadata.suffix}
        </h5>
      );
    } else if (metadata.firstName) {
      return (
        <h5 className="card-text">{metadata.firstName} {metadata.suffix}</h5>
      );
    } else if (metadata.lastName) {
      return (
        <h5 className="card-text">{metadata.lastName} {metadata.suffix}</h5>
      );
    }
  }

  // Return a styled version of the decedent's ssn, if an ssn is available.
  decedentSsn() {
    var metadata = this.props.deathRecord.metadata;
    if (!(metadata.ssn1 || metadata.ssn2 || metadata.ssn3)) {
      return;
    }
    // Format ssn
    return (
      <h6 className="card-text">
        {metadata.ssn1}
        -
        {metadata.ssn2}
        -
        {metadata.ssn3}
      </h6>
    );
  }

  render() {
    return (
      <div className="card night-card text-center night-full-width night-decedent-padding pt-3 pb-2">
        <div className="fa-4x text-center night-center-block">
          <i className="fa fa-2x fa-user-circle text-primary" />
        </div>
        {this.decedentInfo()}
      </div>
    );
  }
}
