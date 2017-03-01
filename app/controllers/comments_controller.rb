# Comments Controller
class CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy, :update]
  before_action :set_death_record, only: [:destroy, :update, :create]

  def create
    authorize :comment, :create?
    @comment = current_user.comments.create(comment_params)

    respond_to do |format|
      format.html { redirect_to death_record_path(@death_record) }
      format.js
    end
  end

  def update
    authroize @comment, :update?
    @comment.update_attributes(comment_params)
  end

  def destroy
    authorize @comment, :delete?
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to death_record_path(@death_record) }
      format.js
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_death_record
    @death_record = DeathRecord.find(params['death_record_id'])
  end

  def comment_params
    params.require(:comment).merge(death_record_id: params['death_record_id']).permit(:content, :death_record_id)
  end
end
