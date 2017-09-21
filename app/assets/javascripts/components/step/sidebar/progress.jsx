// Progress component; shows what step is currently active in the death
// record workflow. Allows the user to jump between steps that they are
// allowed to edit. Also shows step status (is the step as it currently
// stands meeting all required fields).
class Progress extends React.Component {
  constructor(props) {
    super(props);
  }

  statusIcon(step) {
    if (step.contents.contents && step.contents.requiredSatisfied) {
      // All required have been satisfied
      return <i className="fa fa-fw fa-check pull-right text-success" id={step.name + 'status'} />;
    } else if (step.contents.contents) {
      // Not all required have been satisfied
      return <i className="fa fa-fw fa-times pull-right text-danger" id={step.name + 'status'} />;
    }
    // If the step doesn't even have content, show nothing.
  }

  render() {
    return (
      <div className="btn-group-vertical btn-block">
        {this.props.deathRecord.steps.map((step, index) =>
          <button
            key={'prog' + step.name}
            type="button"
            className={'btn btn-block btn-secondary text-left night-step-padding ' + (step.active && 'active')}
            onClick={() => this.props.updateStep(step.name, true)}
            disabled={!step.editable}
            id={'progressButton' + index}
          >
            <i className={'text-primary fa fa-fw ' + step.icon} /> {step.name}
            {this.statusIcon(step)}
          </button>
        )}
      </div>
    );
  }
}
