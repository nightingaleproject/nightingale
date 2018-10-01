// Comment component; shows a user comment.
class Comment extends React.Component {
  constructor(props) {
    super(props);
    this.deleteComment = this.deleteComment.bind(this);
  }

  deleteComment() {
    $.ajax({
      url: Routes.comment_path(this.props.comment.id),
      type: 'DELETE',
      success: function() {
        this.props.removeComment(this.props.comment.id);
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(Routes.comments_path(), status, err.toString());
      }.bind(this)
    });
  }

  render() {
    // Convert datetime comment was created at to a human readable 'time ago'.
    var timeago = jQuery.timeago(this.props.comment.createdAt);

    // Show delete button?
    if (this.props.currentUser.id === this.props.comment.author.id && !this.props.deathRecord.registration) {
      var deleteButton = (
        <div className="float-right">
          <button
            type="button"
            onClick={this.deleteComment}
            className="btn btn-sm btn-danger"
            id={'deleteComment' + this.props.comment.id}
          >
            <span className="fa fa-trash" /> Delete
          </button>
        </div>
      );
    }

    return (
      <div className="card mt-3 mb-3">
        <div className="card-header">
          <div>
            <div>
              <b>{this.props.comment.author.email}</b> {this.props.comment.author.name} ({this.props.comment.author.rolePretty}), {timeago}
              {deleteButton}
            </div>
          </div>
        </div>
        <div className="card-body">
          <p className="card-text">
            {this.props.comment.content}
          </p>
        </div>
      </div>
    );
  }
}
