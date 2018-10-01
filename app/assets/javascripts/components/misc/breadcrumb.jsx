// Breadcrumb component
class Breadcrumb extends React.Component {
  render() {
    return (
      <div className="row">
        <nav className="breadcrumb night-full-width">
          {this.props.crumbs.map(function(crumb) {
            if (crumb.url) {
              return (
                <a key={'bca' + crumb.name} className="breadcrumb-item" href={crumb.url}>
                  {crumb.name}
                </a>
              );
            } else {
              return (
                <span key={'bcs' + crumb.name} className="breadcrumb-item active">
                  {crumb.name}
                </span>
              );
            }
          })}
        </nav>
      </div>
    );
  }
}
