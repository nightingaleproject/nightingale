// SendTo component; allows a user to send a death record to the next user
// in the workflow.
class SendTo extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
    this.getUsersByRole = this.getUsersByRole.bind(this);
    this.sendToUpdate = this.sendToUpdate.bind(this);
    this.changeGuestMode = this.changeGuestMode.bind(this);
    this.canSend = this.canSend.bind(this);
    this.reassign = this.reassign.bind(this);
    this.guestTab = this.guestTab.bind(this);
  }

  componentWillMount() {
    this.setState({
      users: [],
      canSend: false,
      guestMode: false,
      userInfo: {
        firstName: '',
        lastName: '',
        telephone: '',
        guestEmail: '',
        email: '',
        confirmEmail: '',
        linear: true,
        step: this.props.nextStep
      }
    });
    this.getUsersByRole(this.props.deathRecord.nextStepRole);
  }

  getUsersByRole(role) {
    // Get a list of all users who have the given role.
    $.ajax({
      url: Routes.users_by_role_death_record_path(this.props.deathRecord.id),
      dataType: 'json',
      contentType: 'application/json',
      type: 'POST',
      data: JSON.stringify({
        role: role
      }),
      success: function(users) {
        this.setState({
          users: users
        });
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(
          Routes.users_by_role_death_record_path(this.props.deathRecord.id),
          status,
          err.toString()
        );
      }.bind(this)
    });
  }

  canSend(guestMode, userInfo) {
    var canSend = false;
    if (guestMode) {
      if (
        userInfo.guestEmail &&
        userInfo.confirmEmail &&
        userInfo.guestEmail === userInfo.confirmEmail
      ) {
        canSend = true;
      }
    } else if (userInfo.email) {
      canSend = true;
    }
    return canSend;
  }

  sendToUpdate(event) {
    userInfo = { ...this.state.userInfo };
    userInfo[event.target['id']] = event.target.value;
    this.setState({
      userInfo: userInfo,
      canSend: this.canSend(this.state.guestMode, userInfo)
    });
  }

  changeGuestMode(guestMode) {
    this.setState({
      guestMode: guestMode,
      canSend: this.canSend(guestMode, this.state.userInfo)
    });
  }

  reassign(step, linear, userEmail) {
    this.state.userInfo['guestMode'] = this.state.guestMode;
    if (this.state.guestMode) {
      this.state.userInfo['email'] = this.state.userInfo['guestEmail'];
    } else {
      this.state.userInfo['email'] = _.head(
        _.split(this.state.userInfo['email'], ' ')
      );
    }
    info = { ...this.state.userInfo };
    info['step'] = this.state.deathRecord.stepStatus.nextStep.name;
    info['reassign'] = true;
    $.LoadingOverlay('show', {
      image: '',
      fontawesome: 'fa fa-spinner fa-spin'
    });
    $.post(
      Routes.update_active_step_death_record_path(this.props.deathRecord.id),
      info
    );
  }

  guestTab() {
    if (this.props.deathRecord.nextStepRole != 'registrar') {
      return (
        <li className="nav-item">
          <a
            className="nav-link"
            href="#guest"
            role="tab"
            id="guest-tab"
            data-toggle="tab"
            aria-controls="guest"
            onClick={() => this.changeGuestMode(true)}
          >
            Guest
          </a>
        </li>
      );
    }
  }

  render() {
    var prev = this.state.deathRecord.stepStatus.previousStep;
    return (
      <div>
        <div className="row mb-3 mt-5">
          <h4>Send to {this.props.deathRecord.nextStepRolePretty}</h4>
        </div>

        <div className="row">
          <ul
            id="send-to-nav"
            className="nav nav-tabs night-full-width night-send-to-tabs"
            role="tablist"
          >
            <li className="nav-item">
              <a
                className="nav-link active"
                href="#user"
                id="user-tab"
                role="tab"
                data-toggle="tab"
                aria-controls="user"
                aria-expanded="true"
                onClick={() => this.changeGuestMode(false)}
              >
                Existing User
              </a>
            </li>
            {this.guestTab()}
          </ul>
        </div>

        <div className="row">

          <div
            id="send-to-nav-content"
            className="tab-content mb-4 night-full-width"
          >
            <div
              role="tabpanel"
              className="tab-pane fade show active night-send-to night-send-to-user"
              id="user"
              aria-labelledby="user-tab"
            >
              <div className="row mt-4 ml-3 mr-3">
                <h6>
                  Select a {this.props.deathRecord.nextStepRolePretty} with an
                  existing account on Nightingale that you wish to send this
                  Death Record to.
                </h6>
              </div>
              <div className="row mt-3 mb-4 ml-3 mr-3">
                <select
                  id="email"
                  className="user-emails form-control"
                  onChange={this.sendToUpdate}
                  value={this.state.userInfo.email}
                >
                  <option key="blank-option" />
                  {this.state.users.map(user =>
                    <option key={user}>{user}</option>
                  )}
                </select>
              </div>
            </div>

            <div
              role="tabpanel"
              className="tab-pane fade night-send-to-guest"
              id="guest"
              aria-labelledby="guest-tab"
            >
              <div className="row mt-4 ml-3 mr-3">
                <h6>
                  If the {this.props.deathRecord.nextStepRolePretty} does not
                  currently have an account on Nightingale, enter their name,
                  telephone number, and email address below to allow them
                  temporary access to this Death Record.
                </h6>
              </div>
              <div className="row mt-3 mb-3 ml-3 mr-3">
                <form className="night-full-width" id="guest">
                  <div className="form-group row">
                    <label
                      htmlFor="example-text-input"
                      className="col-4 col-form-label"
                    >
                      First Name:
                    </label>
                    <div className="col-8">
                      <input
                        className="form-control"
                        type="text"
                        id="firstName"
                        onChange={this.sendToUpdate}
                        value={this.state.userInfo.first_name}
                      />
                    </div>
                  </div>
                  <div className="form-group row">
                    <label
                      htmlFor="example-text-input"
                      className="col-4 col-form-label"
                    >
                      Last Name:
                    </label>
                    <div className="col-8">
                      <input
                        className="form-control"
                        type="text"
                        id="lastName"
                        onChange={this.sendToUpdate}
                        value={this.state.userInfo.last_name}
                      />
                    </div>
                  </div>
                  <div className="form-group row">
                    <label
                      htmlFor="example-text-input"
                      className="col-4 col-form-label"
                    >
                      Telephone Number:
                    </label>
                    <div className="col-8">
                      <input
                        className="form-control"
                        type="text"
                        id="telephone"
                        onChange={this.sendToUpdate}
                        value={this.state.userInfo.telephone}
                      />
                    </div>
                  </div>
                  <div className="form-group row">
                    <label
                      htmlFor="example-text-input"
                      className="col-4 col-form-label"
                    >
                      Email:
                    </label>
                    <div className="col-8">
                      <input
                        className="form-control"
                        type="text"
                        id="guestEmail"
                        onChange={this.sendToUpdate}
                        value={this.state.userInfo.guest_email}
                      />
                    </div>
                  </div>
                  <div className="form-group row">
                    <label
                      htmlFor="example-text-input"
                      className="col-4 col-form-label"
                    >
                      Confirm Email:
                    </label>
                    <div className="col-8">
                      <input
                        className="form-control"
                        type="text"
                        id="confirmEmail"
                        onChange={this.sendToUpdate}
                        value={this.state.userInfo.confirm_email}
                      />
                    </div>
                  </div>
                </form>
              </div>
            </div>

            <div className="pull-right mt-3">
              <a
                href={Routes.death_records_path()}
                className="btn btn-secondary mr-2"
              >
                Cancel
              </a>
              <button
                type="button"
                className="btn btn-primary mr-2"
                onClick={() =>
                  this.reassign(
                    this.props.deathRecord.stepStatus.nextStep,
                    true,
                    this.state.userEmail
                  )}
                disabled={!this.state.canSend}
              >
                Send
              </button>
            </div>

          </div>
        </div>
      </div>
    );
  }
}
