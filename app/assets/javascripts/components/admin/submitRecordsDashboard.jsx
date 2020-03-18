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

    const showRecord = (record) => {
      return (
        <tr key={record.id}>
          <td>{record.id}</td>
          <td><a href={"/death_records/" + record.id}>{record.name}</a></td>
          <td style={{textAlign: "center"}}>{record.voided ? <i className="fa fa-check"></i> : ''}</td>
          <td style={{textAlign: "center"}}>{record.submitted ? <i className="fa fa-check"></i> : ''}</td>
          <td style={{textAlign: "center"}}>{record.acknowledgement_message_id != null ? <a href={"/show_message/" + record.acknowledgement_message_id}><i className="fa fa-check"></i></a> : ''}</td>
          <td style={{textAlign: "center"}}>{record.coding_message_id != null ? <a href={"/show_message/" + record.coding_message_id}><i className="fa fa-check"></i></a> : ''}</td>
          <td>{record.underlying_cause_code}</td>
        </tr>
      );
    };

    const showRecords = (records) => {
      return (
          <table className="table table-striped table-hover table-sm">
            <thead>
              <tr>
                <th>ID</th>
                <th>Decedent Name</th>
                <th style={{textAlign: "center"}}>Voided</th>
                <th style={{textAlign: "center"}}>Submitted</th>
                <th style={{textAlign: "center"}}>Acknowledged</th>
                <th style={{textAlign: "center"}}>Coded</th>
                <th>Underlying COD</th>
              </tr>
            </thead>
            <tbody>
              {records.map(showRecord)}
            </tbody>
          </table>
      );
    };

    return (
      <div>
        <div className="h4 my-4">
          <span className="mr-4">Records: {this.state.record_count || 0}</span>
          <span className="mx-4">Submitted: {this.state.submitted_record_count || 0}</span>
          <span className="mx-4">Acknowledged: {this.state.acknowledged_record_count || 0}</span>
          <span className="mx-4">Coded: {this.state.coded_record_count || 0}</span>
        </div>
        {showRecords(this.state.records || [])}
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
