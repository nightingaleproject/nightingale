// OwnedRecords component; makes up the owned records list.
class AuditLogs extends React.Component {
    constructor(props) {
      super(props);
      this.state = this.props;
      
      this.decedentName = this.decedentName.bind(this);


      this.renderActionCol = this.renderActionCol.bind(this);
      this.renderTypeCol = this.renderTypeCol.bind(this);

      this.renderCreatedCol = this.renderCreatedCol.bind(this);
    }
  
    componentDidMount() {
      var self = this;
      $(function() {
        var emptyMessage = 'No audit logs generated.';
        
        $('#audits_table').DataTable({
          language: {
            emptyTable: emptyMessage,
            info: '',
            infoEmpty: '',
            infoFiltered: '',
            search: 'Search:',
            processing: "<span class='fa fa-spinner fa-spin fa-5x fa-fw'></span>"
          },
          ordering: true,
          columnDefs: [
            {
              className: 'details-control',
              orderable: false,
              searchable: true,
              width: '6%',
              targets: [0],
              data: null,
            //   render: self.renderNotificationCol
            },
            {
              searchable: true,
              width: '6%',
              targets: [1],
              data: null,
              render: self.renderActionCol
            },
            { 
              searchable: true,  
              width: '8%', 
              targets: [2], 
              data: null, 
              render: self.renderTypeCol 
            },
            {
              searchable: true,
              width: '28%',
              targets: [3],
              data: null,
              render: self.renderCreatedCol 
            },
            {
              searchable: true,
              width: '28%',
              targets: [4],
              data: null,
            //  render: self.renderTimeagoCol
            },
            {
              searchable: true,
              visible: false,
              width: '24%',
              targets: [5],
              data: null,
             // render: self.renderProgressCol
            }
          ],
          processing: true,
          serverSide: true,
          ajax: {
            url: Routes.audit_logs_reports_path(),
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
  
    renderActionCol(data, type, full, meta) {
      return ReactDOMServer.renderToStaticMarkup(this.renderAction(data));
    }

    renderTypeCol(data, type, full, meta) {
      return ReactDOMServer.renderToStaticMarkup(this.renderType(data));
    }

    renderCreatedCol(data, type, full, meta) {
      return ReactDOMServer.renderToStaticMarkup(this.renderCreatedAt(data));
    }
  
    renderProgressCol(data, type, full, meta) {
      return this.renderRecordProgress(data);
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
            <i className="fa fa-check-circle text-success night-progress-icon" />
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
            <i className="fa fa-times-circle text-danger night-progress-icon" />
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
            <i className="fa fa-circle-o text-muted night-progress-icon" />
            &nbsp;
          </a>
        );
      }
    }
  
    renderAction(data) {
      return (
        <span>
          {data.action}
        </span>
      );
    }
  
    renderType(data) {
      return (
        <span>
          {data.type}
        </span>
      );
    }

    renderCreatedAt(data) {
      return (
        <span>
          {data.created_at}
        </span>
      )
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
  
    render() {
      return (
        <div className="mb-5 mt-2">
          <div className="row mb-4">
            <div className="col-4 pl-0">
              {this.state.currentUser.isAdmin &&
                <h3>
                  <span className="fa fa-folder" /> Audit Logs
                </h3>}
            </div>
          </div>
          <div className="row">
            <table className="table" id="audits_table" key={this.props.currentUser.id + 'audits-table'} width="100%">
              <thead key={this.props.currentUser.id + 'audits-head'}>
                <tr>
                  <th />
                  <th>Change</th>
                  <th>Action</th>
                  <th>Type</th>
                  <th>When</th>
                  <th>Who</th>
                  <th>Change</th>
               </tr>
              </thead>
              <tbody key={this.props.currentUser.id + 'audits-body'} />
            </table>
          </div>
        </div>
      );
    }
  }
  