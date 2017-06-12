// TransferredRecords component; makes up the transferred records list.
class TransferredRecords extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
    this.renderRecord = this.renderRecord.bind(this);
    this.renderRecordProgressIcon = this.renderRecordProgressIcon.bind(this);
    this.renderRecordProgress = this.renderRecordProgress.bind(this);
    this.decedentName = this.decedentName.bind(this);
    this.renderDecedentName = this.renderDecedentName.bind(this);
  }

  componentDidMount() {
    $(function() {
      $('[data-toggle="tooltip"]').tooltip();
    });
  }

  componentDidMount() {
    var self = this;
    $(function() {
      if (self.props.currentUser.isAdmin) {
        var emptyMessage = 'No death records in the system.';
      } else {
        var emptyMessage = 'No death records to show.';
      }
      $('[data-toggle="tooltip"]').tooltip();
      $('#transferred_records').DataTable({
        language: {
          emptyTable: emptyMessage,
          lengthMenu: 'Display _MENU_ records',
          info: 'Showing _PAGE_ of _PAGES_'
        },
        ordering: false,
        columnDefs: [
          { searchable: false, width: '6%', targets: [0] },
          { width: '8%', targets: [1] },
          { width: '30%', targets: [2] },
          { width: '28%', targets: [3] },
          { searchable: false, width: '28%', targets: [4] }
        ]
      });
    });
  }

  renderRecord(deathRecord) {
    var decedentName = this.decedentName(deathRecord);
    var timeago = jQuery.timeago(deathRecord.lastUpdatedAt);
    return (
      <tr key={deathRecord.id}>
        <td>
          <div className="btn-group btn-block" role="group">
            <button
              id="btnGroupDrop1"
              type="button"
              className="btn btn-block btn-primary btn-block dropdown-toggle btn-sm"
              data-toggle="dropdown"
              aria-haspopup="true"
              aria-expanded="false"
            >
              <i className="fa fa-cog" />
            </button>
            <div className="dropdown-menu" aria-labelledby="btnGroupDrop1">
              <a className="dropdown-item" href={Routes.death_record_path(deathRecord.id)}>
                <i className="fa fa-search" />&nbsp;View
              </a>
            </div>
          </div>
        </td>
        <td>{deathRecord.id}</td>
        <td>{this.renderDecedentName(decedentName)}</td>
        <td>{timeago}</td>
        <td>{this.renderRecordProgress(deathRecord)}</td>
      </tr>
    );
  }

  renderRecordProgressIcon(step, deathRecord) {
    if (step.contents.contents && step.contents.requiredSatisfied) {
      return (
        <a
          data-toggle="tooltip"
          data-animation="false"
          data-placement="top"
          title={step.name}
          key={deathRecord.id + step.name}
        >
          <i className="fa fa-check-circle text-success night-progress-icon" />
        </a>
      );
    } else if (step.contents.contents) {
      return (
        <a
          data-toggle="tooltip"
          data-animation="false"
          data-placement="top"
          title={step.name}
          key={deathRecord.id + step.name}
        >
          <i className="fa fa-times-circle text-danger night-progress-icon" />
        </a>
      );
    } else {
      return (
        <a
          data-toggle="tooltip"
          data-animation="false"
          data-placement="top"
          title={step.name}
          key={deathRecord.id + step.name}
        >
          <i className="fa fa-circle-o text-muted night-progress-icon" />
        </a>
      );
    }
  }

  renderRecordProgress(deathRecord) {
    if (deathRecord.registration) {
      return 'Registered!';
    }
    return deathRecord.steps.map(step => step.type == 'form' && this.renderRecordProgressIcon(step, deathRecord));
  }

  renderDecedentName(name) {
    return <span>{name}</span>;
  }

  // Return a styled version of the decedent's name, constructed by what
  // information is available.
  decedentName(deathRecord) {
    var metadata = deathRecord.metadata;
    // Format name
    if (metadata.firstName && metadata.lastName && metadata.middleName) {
      return metadata.lastName + ', ' + metadata.firstName + ' ' + metadata.middleName[0] + '. ' + metadata.suffix;
    } else if (metadata.firstName && metadata.middleName) {
      return metadata.firstName + ' ' + metadata.middleName[0] + '. ' + metadata.suffix;
    } else if (metadata.firstName && metadata.lastName) {
      return metadata.lastName + ', ' + metadata.firstName + ' ' + metadata.suffix;
    } else if (metadata.firstName) {
      return metadata.firstName + ' ' + metadata.suffix;
    } else if (metadata.lastName) {
      return metadata.lastName + ' ' + metadata.suffix;
    }
  }

  filterTable(event) {
    this.setState({
      search: event.target.value
    });
  }

  render() {
    return (
      <div className="mb-5">
        <div className="row mb-4">
          <div className="col pl-0">
            {!this.props.currentUser.canRegisterRecord && <h3>My Transferred Records</h3>}
            {this.props.currentUser.canRegisterRecord && <h3>Registered Records</h3>}
          </div>
        </div>
        <div className="row">
          <table
            className="table"
            id="transferred_records"
            key={this.props.currentUser.id + 'trans-table'}
            width="100%"
          >
            <thead className="thead-default" key={this.props.currentUser.id + 'trans-head'}>
              <tr>
                <th />
                <th>ID</th>
                <th>Decedent Name</th>
                <th>Last Updated</th>
                <th>Progress</th>
              </tr>
            </thead>
            <tbody key={this.props.currentUser.id + 'trans-body'}>
              {this.props.transferredDeathRecords.map(deathRecord => this.renderRecord(deathRecord))}
            </tbody>
          </table>
        </div>
      </div>
    );
  }
}
