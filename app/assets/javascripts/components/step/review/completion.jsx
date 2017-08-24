// Completion component; shows completion status for each step.
class Completion extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
    this.actionButton = this.actionButton.bind(this);
    this.renderCompletionStatus = this.renderCompletionStatus.bind(this);
    this.renderStepContents = this.renderStepContents.bind(this);
    this.requestEdits = this.requestEdits.bind(this);
  }

  componentDidMount() {
    // Don't toggle collapse of step status preview if button was pressed
    $('.no-collapsable').on('click', function(e) {
      // TODO
      //e.stopPropagation();
    });
  }

  actionButton(step, user) {
    // Death record is registered; no more edit actions.
    if (this.props.deathRecord.registration) {
      return;
    }
    // Can't edit or ask for edits if you don't own the record.
    if (this.props.deathRecord.owner.id != this.props.currentUser.id) {
      return;
    }
    if (step.editable && !this.props.registration) {
      return (
        <div key={'buttondiv' + step.name + user.id} className="pull-right">
          <button
            key={'buttonbutton' + step.name + user.id}
            type="button"
            className="btn btn-sm btn-secondary no-collapsable"
            onClick={() => this.props.updateStep(step.name, false)}
          >
            <span
              key={'buttonspan' + step.name + user.id}
              className="fa fa-pencil"
            />
            {' '}Edit
          </button>
        </div>
      );
    } else if ((user.canRequestEdits || user.isAdmin) && step.contents.editor) {
      return (
        <div key={'buttondiv' + step.name + user.id} className="pull-right">
          <button
            key={'buttonbutton' + step.name + user.id}
            type="button"
            className="btn btn-sm btn-secondary no-collapsable"
            onClick={() => this.requestEdits(step, step.contents.editor)}
          >
            <span
              key={'buttonspan' + step.name + user.id}
              className="fa fa-send"
            />
            {' '}Request Edit
          </button>
        </div>
      );
    }
  }

  requestEdits(step, user) {
    this.props.requestEdits(step, user);
  }

  renderCompletionStatus(step, user) {
    if (step.empty) {
      // Step was never even started
      return (
        <div key={'div' + step.name}>
          <div
            id={step.name}
            className="row alert alert-danger night-full-width night-step-completion"
          >
            <div
              key={'divname' + step.name + user.id}
              className="col-3 text-xs-left"
            >
              <strong>{step.name}</strong>
            </div>
            <div
              key={'divmessage' + step.name + user.id}
              className="col-8 text-xs-left"
            >
              This step was never started!
            </div>
            <div
              key={'divbutton' + step.name + user.id}
              className="col-1 text-xs-left"
            >
              {this.actionButton(step, user)}
            </div>
          </div>
        </div>
      );
    } else if (step.contents && step.contents.requiredSatisfied) {
      // All required complete
      return (
        <div key={'div' + step.name}>
          <div
            id={step.name}
            data-toggle="collapse"
            data-target={'#collapse' + step.name}
            aria-expanded="true"
            aria-controls={'collapse' + step.name}
            className="row alert alert-success night-full-width night-step-completion"
          >
            <div
              key={'divname' + step.name + user.id}
              className="col-3 text-xs-left"
            >
              <strong>{step.name}</strong>
            </div>
            <div
              key={'divmessage' + step.name + user.id}
              className="col-8 text-xs-left"
            >
              All required fields are complete!
            </div>
            <div
              key={'divbutton' + step.name + user.id}
              className="col-1 text-xs-left"
            >
              {this.actionButton(step, user)}
            </div>
          </div>
          <div
            id={'collapse' + step.name}
            className={'collapse mb-3 ' + (this.props.registration && ' show')}
            aria-labelledby={step.name}
          >
            <div className="card-block">
              {this.renderStepContents(step)}
            </div>
          </div>
        </div>
      );
    } else if (step.contents && !step.contents.requiredSatisfied) {
      // Some required fields were not completed
      return (
        <div key={'div' + step.name}>
          <div
            id={step.name}
            data-toggle="collapse"
            data-target={'#collapse' + step.name}
            aria-expanded="true"
            aria-controls={'collapse' + step.name}
            className="row alert alert-danger night-full-width night-step-completion"
          >
            <div
              key={'divname' + step.name + user.id}
              className="col-3 text-xs-left"
            >
              <strong>{step.name}</strong>
            </div>
            <div
              key={'divmessage' + step.name + user.id}
              className="col-8 text-xs-left"
            >
              Some required fields are not complete!
            </div>
            <div
              key={'divbutton' + step.name + user.id}
              className="col-1 text-xs-left"
            >
              {this.actionButton(step, user)}
            </div>
          </div>
          <div
            id={'collapse' + step.name}
            className={'collapse mb-3 ' + (this.props.registration && ' show')}
            aria-labelledby={step.name}
          >
            <div className="card-block">
              {this.renderStepContents(step)}
            </div>
          </div>
        </div>
      );
    }
  }

  renderStepContents(step) {
    if (!step || step.empty) {
      return <span>Nothing to show.</span>;
    }
    return (
      <div>
        {step.contents.results.map(result =>
          <dl className="row" key={result.title}>
            <dt className="p-2 col-sm-4">{result.title}</dt>
            <dd
              className={
                'rounded p-2 night-full-width col-sm-8' +
                (!result.isRequired && ' alert-info ') +
                (result.isRequired &&
                  result.requiredSatisfied &&
                  ' alert-success ') +
                (result.isRequired &&
                  !result.requiredSatisfied &&
                  ' alert-danger ')
              }
            >
              {result.isRequired &&
                result.requiredSatisfied &&
                <i className="fa fa-fw fa-check">&nbsp;</i>}
              {result.isRequired &&
                !result.requiredSatisfied &&
                <i className="fa fa-fw fa-times">&nbsp;</i>}
              {result.humanReadable.split('\\n').map((item, key) => {
                return <span key={key}>{item}<br /></span>;
              })}
            </dd>
          </dl>
        )}
      </div>
    );
  }

  render() {
    var user = this.props.currentUser;
    return (
      <div className="pb-2">
        {!this.props.registration &&
          <div className="row mb-3 mt-2"><h4>Completion Status</h4></div>}
        <div id="accordion" role="tablist" aria-multiselectable="true">
          {this.props.deathRecord.steps
            .filter(
              step =>
              step.type === 'form'
            )
            .map(step => this.renderCompletionStatus(step, user))}
        </div>
      </div>
    );
  }
}
