// OwnedRecords component; makes up the owned records list.
class OwnedRecords extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
    this.renderRecordProgressIcon = this.renderRecordProgressIcon.bind(this);
    this.renderRecordProgress = this.renderRecordProgress.bind(this);
    this.decedentName = this.decedentName.bind(this);
    this.renderDecedentName = this.renderDecedentName.bind(this);
    this.renderNotificationCol = this.renderNotificationCol.bind(this);
    this.renderActionButtonsCol = this.renderActionButtonsCol.bind(this);
    this.renderIdCol = this.renderIdCol.bind(this);
    this.renderNameCol = this.renderNameCol.bind(this);
    this.renderTimeagoCol = this.renderTimeagoCol.bind(this);
    this.renderProgressCol = this.renderProgressCol.bind(this);
  }

  componentDidMount() {
    var self = this;
    $(function() {
      if (self.props.currentUser.isAdmin) {
        var emptyMessage = 'No death records in the system.';
      } else {
        var emptyMessage = 'You currently have no open death records.';
      }
      $('#open_records').DataTable({
        language: {
          emptyTable: emptyMessage,
          lengthMenu: 'Display _MENU_ records',
          info: '',
          infoEmpty: '',
          infoFiltered: '',
          search: 'Search by Name:',
          processing: "<span class='fa fa-spinner fa-spin fa-5x fa-fw'></span>"
        },
        ordering: false,
        columnDefs: [
          {
            searchable: false,
            width: '6%',
            targets: [0],
            data: null,
            render: self.renderNotificationCol
          },
          {
            searchable: false,
            width: '6%',
            targets: [1],
            data: null,
            render: self.renderActionButtonsCol
          },
          { width: '8%', targets: [2], data: null, render: self.renderIdCol },
          {
            width: '28%',
            targets: [3],
            data: null,
            render: self.renderNameCol
          },
          {
            width: '28%',
            targets: [4],
            data: null,
            render: self.renderTimeagoCol
          },
          {
            searchable: false,
            width: '24%',
            targets: [5],
            data: null,
            render: self.renderProgressCol
          }
        ],
        processing: true,
        serverSide: true,
        ajax: {
          url: Routes.owned_death_records_death_records_path(),
          type: 'POST'
        },
        pagingType: 'simple',
        lengthMenu: [10, 25, 50],
        drawCallback: function(settings) {
          $('[data-toggle="tooltip"]').tooltip();
        }
      });
    });
  }

  renderNotificationCol(data, type, full, meta) {
    if (data.notify && !this.props.currentUser.isAdmin) {
      return ReactDOMServer.renderToStaticMarkup(
        <h6>
          <span className="badge badge-danger full-width mt-1">New!</span>
        </h6>
      );
    } else {
      return '';
    }
  }

  renderActionButtonsCol(data, type, full, meta) {
    if (this.props.currentUser.isAdmin) {
      return ReactDOMServer.renderToStaticMarkup(
        <div className="btn-group btn-block" role="group">
          <button
            id="btnGroupDrop1"
            type="button"
            className="btn btn-primary btn-block dropdown-toggle btn-sm"
            data-toggle="dropdown"
            aria-haspopup="true"
            aria-expanded="false"
          >
            <i className="fa fa-download" />
          </button>
          <div className="dropdown-menu" aria-labelledby="btnGroupDrop1">
            <a href={Routes.export_record_in_ije_path(data.id)} className="dropdown-item" role="button">IJE</a>
            <a href={Routes.export_record_in_fhir_json_path(data.id)} className="dropdown-item" role="button">FHIR (JSON)</a>
            <a href={Routes.export_record_in_fhir_xml_path(data.id)} className="dropdown-item" role="button">FHIR (XML)</a>
          </div>
        </div>
      );
    }
    return ReactDOMServer.renderToStaticMarkup(
      <div className="btn-group btn-block" role="group">
        <button
          id="btnGroupDrop1"
          type="button"
          className="btn btn-primary btn-block dropdown-toggle btn-sm"
          data-toggle="dropdown"
          aria-haspopup="true"
          aria-expanded="false"
        >
          <i className="fa fa-cog" />
        </button>
        <div className="dropdown-menu" aria-labelledby="btnGroupDrop1">
          {!this.props.currentUser.canRegisterRecord &&
            !this.props.currentUser.isAdmin &&
            <a className="dropdown-item" href={Routes.edit_death_record_path(data.id)} id={'continue' + data.id}>
              <i className="fa fa-play" />&nbsp;Continue
            </a>}
          <a className="dropdown-item" href={Routes.death_record_path(data.id)} id={'view' + data.id}>
            <i className="fa fa-search" />&nbsp;View
          </a>
        </div>
      </div>
    );
  }

  renderIdCol(data, type, full, meta) {
    return data.id;
  }

  renderNameCol(data, type, full, meta) {
    return ReactDOMServer.renderToStaticMarkup(this.renderDecedentName(this.decedentName(data)));
  }

  renderTimeagoCol(data, type, full, meta) {
    return jQuery.timeago(data.lastUpdatedAt);
  }

  renderProgressCol(data, type, full, meta) {
    if (data.registration) {
      return 'Registered!';
    } else {
      return this.renderRecordProgress(data);
    }
  }

  renderRecordProgressIcon(step, deathRecord) {
    if (step.contents.contents && step.contents.requiredSatisfied) {
      return ReactDOMServer.renderToStaticMarkup(
        <a
          data-toggle="tooltip"
          data-animation="false"
          data-placement="top"
          title={step.name}
          key={deathRecord.id + step.name}
        >
          <i className="fa fa-check-circle text-success night-progress-icon" id={step.name + 'prog'} />
          &nbsp;
        </a>
      );
    } else if (step.contents.contents) {
      return ReactDOMServer.renderToStaticMarkup(
        <a
          data-toggle="tooltip"
          data-animation="false"
          data-placement="top"
          title={step.name}
          key={deathRecord.id + step.name}
        >
          <i className="fa fa-times-circle text-danger night-progress-icon" id={step.name + 'prog'} />
          &nbsp;
        </a>
      );
    } else {
      return ReactDOMServer.renderToStaticMarkup(
        <a
          data-toggle="tooltip"
          data-animation="false"
          data-placement="top"
          title={step.name}
          key={deathRecord.id + step.name}
        >
          <i className="fa fa-circle-o text-muted night-progress-icon" id={step.name + 'prog'} />
          &nbsp;
        </a>
      );
    }
  }

  renderRecordProgress(deathRecord) {
    var progress = '';
    for (var step of deathRecord.steps) {
      var stepProgress = this.renderRecordProgressIcon(step, deathRecord);
      if (step.type == 'form' && stepProgress) {
        progress += stepProgress;
      }
    }
    return progress;
  }

  renderDecedentName(name) {
    return (
      <span>
        {name}
      </span>
    );
  }

  // Return a styled version of the decedent's name, constructed by what
  // information is available.
  decedentName(deathRecord) {
    var metadata = deathRecord.metadata;
    var suffix = metadata.suffix;
    if (!suffix) {
      suffix = '';
    }
    // Format name
    if (metadata.firstName && metadata.lastName && metadata.middleName) {
      return metadata.lastName + ', ' + metadata.firstName + ' ' + metadata.middleName[0] + '. ' + suffix;
    } else if (metadata.firstName && metadata.middleName) {
      return metadata.firstName + ' ' + metadata.middleName[0] + '. ' + suffix;
    } else if (metadata.firstName && metadata.lastName) {
      return metadata.lastName + ', ' + metadata.firstName + ' ' + suffix;
    } else if (metadata.firstName) {
      return metadata.firstName + ' ' + suffix;
    } else if (metadata.lastName) {
      return metadata.lastName + ' ' + suffix;
    }
  }

  render() {
    return (
      <div className="mb-5 mt-2" id="open">
        <div className="row mb-4">
          <div className="col-4 pl-0">
            {this.state.currentUser.isAdmin &&
              <h3>
                <span className="fa fa-folder" /> All Records
              </h3>}
            {!this.state.currentUser.isAdmin &&
              <h3>
                <span className="fa fa-folder" /> My Open Records
              </h3>}
          </div>
          <div className="col-8 pr-0">
            <span className="ml-3 pull-right" />
            {this.props.currentUser.canStartRecord &&
              <span className="pull-right">
                <a role="button" href={Routes.new_death_record_path()} className="btn btn-primary">
                  <i className="fa fa-plus" />&nbsp;New Death Record
                </a>
              </span>}
          </div>
        </div>
        <div className="row">
          <table className="table" id="open_records" key={this.props.currentUser.id + 'owned-table'} width="100%">
            <thead key={this.props.currentUser.id + 'owned-head'}>
              <tr>
                <th />
                <th />
                <th>ID</th>
                <th>Decedent Name</th>
                <th>Last Updated</th>
                <th>Progress</th>
              </tr>
            </thead>
            <tbody key={this.props.currentUser.id + 'owned-body'} />
          </table>
        </div>
      </div>
    );
  }
}
