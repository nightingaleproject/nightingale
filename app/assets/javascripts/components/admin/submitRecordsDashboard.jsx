// Dashboard to show the current state of records being submitted via
// FHIR Messaging, intended as a demonstration to provide visibility
// into how the data flows between systems

class SubmitRecordsDashboard extends React.Component {

  constructor(props) {
    super(props)
    this.state = {};
  }

  render() {

    if (!this.props.currentUser.isAdmin) {
      return <div />;
    }

    return (
      <div>
        <div>Records: {this.state.record_count || 0}</div>
        <div>Submitted Records: {this.state.submitted_record_count || 0}</div>
        <div>Acknowledged Records: {this.state.acknowledged_record_count || 0}</div>
        <div>Coded Records: {this.state.coded_record_count || 0}</div>
      </div>
    );
  }

  refresh() {
    fetch('/submit_records_status.json')
      .then(response => response.json())
      .then(data => this.setState(data));
  }

  componentDidMount() {
    this.refresh();
    this.timer = window.setInterval(() => this.refresh(), 1000)
  }

  componentWillUnmount() {
    window.clearInterval(this.timer)
  }

}
