// Comments component; shows all user comments made for the active
// death record. Also allows a user to make a new comment.
class Comments extends React.Component {
  constructor(props) {
    super(props);
    this.updateInputValue = this.updateInputValue.bind(this);
    this.saveComment = this.saveComment.bind(this);
    this.removeComment = this.removeComment.bind(this);
    this.state = {
      inputValue: '',
      comments: this.props.deathRecord.comments
    };
  }

  updateInputValue(evt) {
    this.setState({
      inputValue: evt.target.value
    });
  }

  removeComment(id) {
    var comments = [...this.state.comments];
    this.setState({
      comments: _.remove(comments, function(comment) {
        return comment.id != id;
      })
    });
  }

  saveComment() {
    $.ajax({
      url: Routes.comments_path(),
      dataType: 'json',
      contentType: 'application/json',
      type: 'POST',
      data: JSON.stringify({
        content: this.state.inputValue,
        death_record_id: this.props.deathRecord.id
      }),
      success: function(comment) {
        var comments = [...this.state.comments];
        comments.push(comment);
        this.setState({
          comments: comments,
          inputValue: ''
        });
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(Routes.comments_path(), status, err.toString());
      }.bind(this)
    });
  }

  render() {
    return (
      <div className="night-full-width mb-5">
        <hr className="mb-4" />
        <h4>Comments</h4>
        {this.state.comments.map(comment =>
          <Comment
            key={'comment' + comment.id}
            comment={comment}
            currentUser={this.props.currentUser}
            deathRecord={this.props.deathRecord}
            removeComment={this.removeComment.bind(this)}
          />
        )}
        {!this.props.currentUser.isAdmin &&
          this.props.allowAdd &&
          <div>
            <div className="form-group mt-4">
              <h6>Add a new comment:</h6>
              <textarea
                onChange={this.updateInputValue}
                value={this.state.inputValue}
                className="form-control"
                rows="3"
                id="commentArea"
              />
            </div>
            <button
              type="button"
              onClick={this.saveComment}
              disabled={!this.state.inputValue}
              className="btn btn-primary float-right"
              id="submitComment"
            >
              Submit Comment
            </button>
          </div>}
      </div>
    );
  }
}
