# Comment Policy File
class CommentPolicy
  def initialize(user, comment)
    @user = user
    @comment = comment
  end

  def create?
    # TODO: How would this be checked?
    true
  end

  def delete?
    @comment.user == @user
  end

  def update?
    @comment.user == @user
  end
end
