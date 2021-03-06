// Audits component; makes up the root audits view.
class Audits extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
  }

  render() {
    return (
      <div className="pt-3">
        <Breadcrumb
          crumbs={[
            { name: 'Dashboard', url: Routes.death_records_path() },
            { name: 'Administration', url: Routes.admins_path() },
            { name: 'Audits', url: Routes.reports_path() }
          ]}
          currentUser={this.state.currentUser}
        />
        {this.state.currentUser.isAdmin && (
          <AuditLogs currentUser={this.state.currentUser} ownedDeathRecords={this.state.ownedDeathRecords} />
        )}
      </div>
    );
  }
}
