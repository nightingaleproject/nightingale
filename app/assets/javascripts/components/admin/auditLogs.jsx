// Audit Logs component; makes up the audit records list.
class AuditLogs extends React.Component {
  constructor(props) {
    super(props);
    this.state = props;
    this.renderChangeCol = this.renderChangeCol.bind(this);
    this.renderActionCol = this.renderActionCol.bind(this);
    this.renderTypeCol = this.renderTypeCol.bind(this);
    this.renderCreatedCol = this.renderCreatedCol.bind(this);
    this.renderWhoCol = this.renderWhoCol.bind(this);
    this.formatData = this.formatData.bind(this);
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
            width: '15%',
            targets: [0],
            data: null,
            render: self.renderChangeCol
          },
          {
            searchable: true,
            width: '15%',
            targets: [1],
            data: null,
            render: self.renderActionCol
          },
          {
            searchable: true,
            width: '15%',
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
            render: self.renderWhoCol
          }
        ],
        processing: true,
        serverSide: true,
        ajax: {
          url: Routes.audit_logs_reports_path(),
          type: 'POST'
        },
        pagingType: 'simple',
        lengthMenu: [10, 25, 50]
      });
    });

    $('#audits_table tbody')
      .on('click', 'td.details-control', function() {
        var tr = $(this).closest('tr');
        var row = $('#audits_table')
          .DataTable()
          .row(tr);
        if (row.child.isShown()) {
          // This row is already open - close it
          row.child.hide();
          tr.removeClass('shown');
        } else {
          // Open this row
          row.child(self.formatData(row.data().audited_changes)).show();
          tr.addClass('shown');
        }
      })
      .bind(this);
  }

  // Builds the child table on the fly given the row data.
  formatData(changes) {
    var self = this;
    html =
      "<table class='table' id='audit_changes_table'>" +
      '<thead>' +
      '<tr>' +
      '<th>Field</th>' +
      '<th>From</th>' +
      '<th>To</th>' +
      '</tr>' +
      '<thead>' +
      '<tbody>';
    // Based on the Audit changes the table will handle rendering differently
    Object.keys(changes).map(function(key) {
      html += '<tr>';
      if (key == 'contents' && Array.isArray(changes[key])) {
        // Step Content Has changed
        var change = changes[key];
        for (i = 0; i < change.length; i++) {
          // Structure of changes is |'symbol', 'key', 'value1', 'value2'|
          html += '<tr><td>';
          if (change[i][1] != 'undefined' && change[i][1] != null) {
            html += change[i][1];
          }
          html += '</td><td>';
          if (change[i].length < 4) {
            // If there is no 4th element, then we know its a new value
            html += 'New</td><td>';
          } else {
            html += self.renderStringFromData(change[i][2]) + '</td><td>';
          }
          if (change[i][3] != 'undefined' && change[i][3] != null) {
            html += self.renderStringFromData(change[i][3]) + '</td>';
          } else {
            html += self.renderStringFromData(change[i][2]) + '</td>';
          }
          html += '<tr>';
        }
      } else {
        html += '<td> ' + key + '</td>';
        if (Array.isArray(changes[key])) {
          // If updated
          html += '<td> ' + changes[key][0] + '</td><td>' + changes[key][1] + '</td>';
        } else {
          // If created
          html += '<td>New</td><td>' + changes[key] + '</td>';
        }
      }
      html += '</tr>';
    });
    html += '</tbody></table>';
    return html;
  }

  // Given a String, an Array of Strings or and Array of Objects, or an Object
  // This will parse it into a format for displaying.
  renderStringFromData(data) {
    output = '';
    if (Array.isArray(data)) {
      for (x = 0; x < data.length; x++) {
        if (typeof data[x] == 'object') {
          Object.keys(data[x]).map(function(key) {
            if (data[x][key]) {
              output += data[x][key] + ', ';
            }
          });
        } else {
          output += data[x] + ', ';
        }
      }
    } else {
      output = data;
    }
    return output;
  }

  renderChangeCol(data, type, full, meta) {
    return '';
  }

  renderActionCol(data, type, full, meta) {
    return ReactDOMServer.renderToStaticMarkup(<span>{data.action}</span>);
  }

  renderTypeCol(data, type, full, meta) {
    return ReactDOMServer.renderToStaticMarkup(<span>{data.auditable_type}</span>);
  }

  renderCreatedCol(data, type, full, meta) {
    return ReactDOMServer.renderToStaticMarkup(<span>{data.created_at}</span>);
  }

  renderWhoCol(data, type, full, meta) {
    return ReactDOMServer.renderToStaticMarkup(this.renderWho(data));
  }

  renderWho(data) {
    if (data.user) {
      return <span>{data.user.email}</span>;
    } else {
      return <span>No user associated</span>;
    }
  }

  render() {
    return (
      <div className="mb-5 mt-2">
        <div className="row mb-4">
          <div className="col-4 pl-0">
            {this.state.currentUser.isAdmin && (
              <h3>
                <span className="fa fa-folder" /> Audit Logs
              </h3>
            )}
          </div>
        </div>
        <div className="row">
          <table className="table" id="audits_table" key={this.props.currentUser.id + 'audits-table'} width="100%">
            <thead key={this.props.currentUser.id + 'audits-head'}>
              <tr>
                <th>Changes</th>
                <th>Action</th>
                <th>Type</th>
                <th>When</th>
                <th>Who</th>
              </tr>
            </thead>
            <tbody key={this.props.currentUser.id + 'audits-body'} />
          </table>
        </div>
      </div>
    );
  }
}
