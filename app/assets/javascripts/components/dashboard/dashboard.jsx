// Dashboard component; makes up the root dashboard view.
class Dashboard extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
  }

  render() {
    return (
      <div className="pt-3">
        <Breadcrumb
          crumbs={[{ name: 'Dashboard', url: Routes.death_records_path() }]}
          currentUser={this.state.currentUser}
        />
        {!this.state.currentUser.isAdmin && !this.state.currentUser.isRegistrar && <DashboardCharts />}
        <OwnedRecords currentUser={this.state.currentUser} ownedDeathRecords={this.state.ownedDeathRecords} />
        {!this.state.currentUser.isAdmin &&
          <TransferredRecords
            currentUser={this.state.currentUser}
            transferredDeathRecords={this.state.transferredDeathRecords}
          />}
      </div>
    );
  }
}
