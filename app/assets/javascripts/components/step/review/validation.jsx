// Validation component; makes up the validation view.
class Validation extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
    this.validate = this.validate.bind(this);
  }

  validate() {
    $.ajax({
      url: Routes.views_validate_death_records_path(this.state.deathRecord.id),
      dataType: 'json',
      contentType: 'application/json',
      type: 'POST',
      success: function(messages) {
        debugger;
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(Routes.views_validate_death_records_path(this.props.deathRecord.id), status, err.toString());
      }.bind(this)
    });
  }

  // <div className="row night-full-width night-step-completion">
  //   <div className="col-md-6 px-0 pt-2">
  //   </div>
  //   <div className="col-md-6 px-0">
  //     <button className="btn btn-primary float-right" onClick={this.validate}>Validate this Record</button>
  //   </div>
  // </div>

  render() {
    return <div className="mt-1" />;
  }
}
