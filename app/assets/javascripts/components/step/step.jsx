// Step component; makes up the root edit view.
class Step extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
    this.onChange = this.onChange.bind(this);
    this.updateStep = this.updateStep.bind(this);
    this.onSave = this.onSave.bind(this);
    this.renderStepEdit = this.renderStepEdit.bind(this);
    this.renderStepView = this.renderStepView.bind(this);
    this.register = this.register.bind(this);
    this.onUnload = this.onUnload.bind(this);
    this.requestEdits = this.requestEdits.bind(this);
    this.abandonRecord = this.abandonRecord.bind(this);
  }

  componentDidMount() {
    this.lastSaveContents = {
      ...this.state.deathRecord.stepStatus.currentStep.contents.contents
    };
  }

  onChange(state) {
    this.setState({ deathRecord: state.deathRecord });
  }

  // Handles updating the currently active step.
  updateStep(step, linear) {
    // We might be moving away from unsaved changes!
    this.onUnload(() => {
      // Don't try to change to a step that is already active.
      if (!_.isEqual(step, this.state.deathRecord.stepStatus.currentStep.name)) {
        $.LoadingOverlay('show', {
          image: '',
          fontawesome: 'fa fa-spinner fa-spin'
        });
        $.ajax({
          url: Routes.update_active_step_death_record_path(this.state.deathRecord.id),
          dataType: 'json',
          contentType: 'application/json',
          type: 'POST',
          data: JSON.stringify({
            step: step,
            linear: linear
          }),
          success: function(deathRecord) {
            $.LoadingOverlay('hide');
            this.setState({
              deathRecord: deathRecord
            });
            // Be carefull about extending {} with an undefined, that will
            // result in an empty object, rather than just undefined.
            if (deathRecord.stepStatus.currentStep.contents.contents) {
              this.lastSaveContents = {
                ...deathRecord.stepStatus.currentStep.contents.contents
              };
            } else {
              this.lastSaveContents = deathRecord.stepStatus.currentStep.contents.contents;
            }
          }.bind(this),
          error: function(xhr, status, err) {
            console.error(
              Routes.update_active_step_death_record_path(this.state.deathRecord.id),
              status,
              err.toString()
            );
          }.bind(this)
        });
      }
    });
  }

  // Handles requesting edits for a record.
  requestEdits(step, user) {
    var self = this;
    swal(
      {
        title: 'Requesting Edits',
        text:
          'You are requesting edits from ' +
          user.email +
          ' (' +
          user.rolePretty +
          ').\nEnter a comment explaining why below:',
        type: 'input',
        showCancelButton: true,
        confirmButtonClass: 'btn-primary',
        confirmButtonText: 'Request Edits',
        closeOnConfirm: false,
        showLoaderOnConfirm: true
      },
      function(input) {
        // Check if user canceled
        if (input != false) {
          // Create comment if any input was given
          if (input) {
            $.post(Routes.comments_path(), {
              content: input,
              death_record_id: self.state.deathRecord.id
            });
          }
          $.post(Routes.request_edits_death_record_path(self.state.deathRecord.id), {
            step: step.name,
            email: user.email
          });
        }
      }
    );
  }

  // Handles saving a step.
  onSave(callback) {
    $.LoadingOverlay('show', {
      image: '',
      fontawesome: 'fa fa-spinner fa-spin'
    });
    $.ajax({
      url: Routes.update_step_death_record_path(this.state.deathRecord.id),
      dataType: 'json',
      contentType: 'application/json',
      type: 'POST',
      data: JSON.stringify(this.state.deathRecord.stepStatus.currentStep.contents.contents),
      success: function(deathRecord) {
        $.LoadingOverlay('hide');
        if (_.isFunction(callback)) {
          callback();
        } else {
          this.setState(
            {
              deathRecord: deathRecord
            },
            () => {
              this.lastSaveContents = {
                ...this.state.deathRecord.stepStatus.currentStep.contents.contents
              };
            }
          );
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(Routes.update_step_death_record_path(this.state.deathRecord.id), status, err.toString());
      }.bind(this)
    });
  }

  // We want to be sure to alert the user if they have unsaved changes before
  // they navigate between steps.
  onUnload(callback) {
    if (!_.isFunction(callback)) return;
    // If state of form is not changed, do not proceed.
    if (JSON.stringify(this.lastSaveContents) === '{}') {
      var lastSave = null;
    } else {
      var lastSave = JSON.stringify(this.lastSaveContents);
    }
    if (JSON.stringify(this.state.deathRecord.stepStatus.currentStep.contents.contents) == lastSave) {
      callback();
      return;
    }
    var self = this;
    swal(
      {
        title: 'You have unsaved changes!',
        text: 'Before leaving this step, do you want to save?',
        type: 'error',
        showCancelButton: true,
        cancelButtonClass: 'btn-danger',
        cancelButtonText: "Don't Save",
        confirmButtonText: 'Save',
        closeOnConfirm: true,
        closeOnCancel: true
      },
      function(isConfirm) {
        if (isConfirm) {
          self.onSave(() => {
            callback();
          });
        } else {
          callback();
        }
      }
    );
  }

  abandonRecord(deathRecordId) {
    var self = this;
    swal(
      {
        title: 'You are about to abandon this death record!',
        text: 'Are you sure?',
        type: 'error',
        showCancelButton: true,
        confirmButtonClass: 'btn-primary',
        confirmButtonText: 'Abandon!',
        closeOnConfirm: false,
        showLoaderOnConfirm: true
      },
      function(isConfirm) {
        if (!isConfirm) return;
        $.post(Routes.abandon_death_record_path(deathRecordId));
      }
    );
  }

  // Handles registering the entire death record.
  register() {
    var self = this;
    swal(
      {
        title: 'You are about to register this death record!',
        text: 'Are you sure?',
        type: 'info',
        showCancelButton: true,
        confirmButtonClass: 'btn-primary',
        confirmButtonText: 'Register',
        closeOnConfirm: false,
        showLoaderOnConfirm: true
      },
      function(isConfirm) {
        if (!isConfirm) return;
        $.ajax({
          url: Routes.register_death_record_path(self.state.deathRecord.id),
          dataType: 'json',
          contentType: 'application/json',
          type: 'POST',
          success: function(deathRecord) {
            self.setState({
              deathRecord: deathRecord
            });
            swal('Registered!', 'This death record has been successfully registered.', 'success');
          }.bind(self),
          error: function(xhr, status, err) {
            console.error(Routes.register_death_record_path(self.state.deathRecord.id), status, err.toString());
          }.bind(self)
        });
      }
    );
  }

  // Renders a form component; allows the user to enter information for
  // the active step.
  renderForm() {
    return (
      <Form
        key={'form' + this.state.deathRecord.stepStatus.currentStep.name}
        deathRecord={this.state.deathRecord}
        onChange={this.onChange}
        onSave={this.onSave}
        updateStep={this.updateStep}
      />
    );
  }

  // Renders a review component; allows the user to review the death record,
  // make changes, and send to the next user in the workflow.
  renderReview() {
    return (
      <Review
        key={'review' + this.state.deathRecord.stepStatus.currentStep.name}
        deathRecord={this.state.deathRecord}
        currentUser={this.props.currentUser}
        updateStep={this.updateStep}
        requestEdits={this.requestEdits}
      />
    );
  }

  // Selectively render the correct main view component for the current state.
  renderMain() {
    if (this.state.deathRecord.stepStatus.currentStep.type == 'form') {
      return this.renderForm();
    } else if (this.state.deathRecord.stepStatus.currentStep.type == 'review') {
      return this.renderReview();
    }
  }

  renderStepEdit() {
    return (
      <div className="row">
        <div className="col-md-3">
          <div className="night-sidebar">
            <div className="row mb-4">
              <Decedent deathRecord={this.state.deathRecord} />
            </div>
            <div className="row">
              <Progress deathRecord={this.state.deathRecord} updateStep={this.updateStep} />
            </div>
          </div>
        </div>
        <div className="col-md-9">
          <div className="night-main night-full-width">
            {this.renderMain()}
            <div className="row">
              <Comments deathRecord={this.state.deathRecord} currentUser={this.state.currentUser} allowAdd={true} />
            </div>
          </div>
        </div>
      </div>
    );
  }

  renderStepView() {
    return (
      <div>
        <div>
          <div className="row mb-3 mt-2">
            <div className="col pl-0">
              <span className="pull-left">
                {(!this.state.currentUser.canRegisterRecord || this.state.currentUser.isAdmin) &&
                  <h2 className="pt-2">View Death Record</h2>}
                {this.state.currentUser.canRegisterRecord && <h2 className="pt-2">Registration</h2>}
              </span>
            </div>
            <div className="col pr-0">
              <span className="pull-right">
                {this.state.currentUser.canRegisterRecord &&
                  !this.state.deathRecord.registration &&
                  <button
                    type="button"
                    onClick={this.register}
                    className="btn btn-lg btn-primary pull-right"
                    id="registerBtn"
                  >
                    <span className="fa fa-thumbs-up" /> Register Record
                  </button>}
                {this.state.deathRecord.registration &&
                  <dl className="row pt-3">
                    <dt className="col-sm-5">Registered at</dt>
                    <dd className="col-sm-7">
                      {this.state.deathRecord.registration.registered}
                    </dd>
                    <dt className="col-sm-5">Certificate Number</dt>
                    <dd className="col-sm-7">
                      {this.state.deathRecord.registration.id}
                    </dd>
                  </dl>}
                {!this.state.currentUser.canRegisterRecord &&
                  !this.state.deathRecord.registration &&
                  this.state.deathRecord.creator.id == this.state.currentUser.id &&
                  <button
                    type="button"
                    onClick={() => this.abandonRecord(this.state.deathRecord.id)}
                    className="btn btn-lg btn-primary pull-right"
                    id="abandonBtn"
                  >
                    <span className="fa fa-trash" /> Abandon Record
                  </button>}
              </span>
            </div>
          </div>
        </div>
        <div className="row">
          <Comments
            deathRecord={this.state.deathRecord}
            currentUser={this.state.currentUser}
            allowAdd={!this.state.deathRecord.registration}
          />
        </div>
        <Completion
          deathRecord={this.state.deathRecord}
          updateStep={this.updateStep}
          requestEdits={this.requestEdits}
          currentUser={this.props.currentUser}
          registration={true}
          all={true}
        />
      </div>
    );
  }

  render() {
    return (
      <div className="mt-3">
        <Breadcrumb
          crumbs={[
            { name: 'Dashboard', url: Routes.death_records_path() },
            { name: this.props.type + ' Death Record' }
          ]}
          currentUser={this.state.currentUser}
        />
        {this.props.type == 'View' && this.renderStepView()}
        {this.props.type == 'Edit' && this.renderStepEdit()}
      </div>
    );
  }
}
