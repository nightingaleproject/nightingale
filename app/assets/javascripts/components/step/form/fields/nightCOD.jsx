// NightCOD; custom field that asks for Cause of Death information.
class NightCOD extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: {},
      immediate: this.props.formData.immediate ? this.props.formData.immediate : '',
      immediateInt: this.props.formData.immediateInt ? this.props.formData.immediateInt : '',
      under1: this.props.formData.under1 ? this.props.formData.under1 : '',
      under1Int: this.props.formData.under1Int ? this.props.formData.under1Int : '',
      under2: this.props.formData.under2 ? this.props.formData.under2 : '',
      under2Int: this.props.formData.under2Int ? this.props.formData.under2Int : '',
      under3: this.props.formData.under3 ? this.props.formData.under3 : '',
      under3Int: this.props.formData.under3Int ? this.props.formData.under3Int : ''
    };
    this.onChange = this.onChange.bind(this);
    this.validate = this.validate.bind(this);
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

  validate() {
    $('#' + this.props.name + 'field').LoadingOverlay('show', {
      image: '',
      fontawesome: 'fas fa-spinner fa-spin'
    });
    self = this;
    $.ajax({
      url: Routes.views_validate_cod_death_records_path(),
      dataType: 'json',
      contentType: 'application/json',
      type: 'POST',
      data: JSON.stringify({ ...this.state }),
      success: function(messages) {
        organized_messages = {};
        for (message of messages) {
          line = message['field'].slice(-1).toLowerCase().charCodeAt(0) - 97;
          description = message['type'] + ': ' + message['message'];
          if (message['suggestions'].length > 0) {
            description += ' Suggestions: ' + message['suggestions'].join(', ');
          }
          organized_messages[line] = description;
        }
        self.setState({
          messages: organized_messages,
          error: null
        });
        $('#' + this.props.name + 'field').LoadingOverlay('hide');
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(Routes.views_validate_cod_death_records_path(), status, err.toString());
        self.setState({ error: err.toString() });
        $('#' + this.props.name + 'field').LoadingOverlay('hide');
      }.bind(this)
    });
  }

  render() {
    return (
      <fieldset className="mt-4 pt-1 pb-2" id={this.props.name + 'field'}>
        <legend>
          {this.props.schema.required && <i className="fas fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        {this.state.error &&
          <div className="col-md-12">
            <div className="alert alert-danger row p-2">
              {this.state.error}
            </div>
          </div>}
        {this.state.messages &&
          this.state.messages[0] &&
          <div className="col-md-12">
            <div className="alert alert-warning row p-2">
              {this.state.messages[0]}
            </div>
          </div>}
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="immediate">Immediate Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.immediate}
              id="immediate"
              onChange={this.onChange('immediate')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="immediateInt">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.immediateInt}
              id="immediateInt"
              onChange={this.onChange('immediateInt')}
            />
          </div>
        </div>
        {this.state.messages &&
          this.state.messages[1] &&
          <div className="col-md-12">
            <div className="alert alert-warning row p-2">
              {this.state.messages[1]}
            </div>
          </div>}
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="under1">Underlying Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under1}
              id="under1"
              onChange={this.onChange('under1')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="under1Int">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under1Int}
              id="under1Int"
              onChange={this.onChange('under1Int')}
            />
          </div>
        </div>
        {this.state.messages &&
          this.state.messages[2] &&
          <div className="col-md-12">
            <div className="alert alert-warning row p-2">
              {this.state.messages[2]}
            </div>
          </div>}
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="under2">Underlying Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under2}
              id="under2"
              onChange={this.onChange('under2')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="under2Int">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under2Int}
              id="under2Int"
              onChange={this.onChange('under2Int')}
            />
          </div>
        </div>
        {this.state.messages &&
          this.state.messages[3] &&
          <div className="col-md-12">
            <div className="alert alert-warning row p-2">
              {this.state.messages[3]}
            </div>
          </div>}
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="under3">Underlying Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under3}
              id="under3"
              onChange={this.onChange('under3')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="under3Int">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under3Int}
              id="under3Int"
              onChange={this.onChange('under3Int')}
            />
          </div>
        </div>
        <div className="row mt-1 mb-2">
          <div className="col-md-12">
            <button className="btn btn-primary float-right" type="button" onClick={this.validate}>
              Validate
            </button>
          </div>
        </div>
      </fieldset>
    );
  }
}
