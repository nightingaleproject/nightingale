// Review component; makes up the send to view.
class Review extends React.Component {
  render() {
    return (
      <div>
        <Completion
          deathRecord={this.props.deathRecord}
          currentUser={this.props.currentUser}
          updateStep={this.props.updateStep}
          requestEdits={this.props.requestEdits}
        />
        <Validation deathRecord={this.props.deathRecord} />
        <SendTo deathRecord={this.props.deathRecord} updateStep={this.props.updateStep} />
      </div>
    );
  }
}
