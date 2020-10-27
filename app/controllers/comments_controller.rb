# Comments Controller
class CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy]
  before_action :set_death_record, only: [:create]

  def create
    # No new comments if the record has been registered.
    return unless @death_record.registration.nil?
    @comment = Comment.create!(content: comment_params[:content], user: current_user, death_record: @death_record, requested_edits: comment_params[:requested_edits] == 'true')
    @death_record.save
    render json: @comment
  end

  def destroy
    # No deleting comments if the record has been registered.
    return unless @comment.death_record.registration.nil?
    @comment.destroy! if @comment.user == current_user
  end

  private

  # Retrieve the Comment requested by id.
  def set_comment
    @comment = current_user.comments.find(params[:id])
  end

  # Retrieve the DeathRecord requested by id (and scope by owner).
  def set_death_record
    @death_record = current_user.owned_death_records.find_by(id: params[:death_record_id])
    # Allow viewing of death records that were touched but aren't
    # currently owned.
    if @death_record.nil?
      set_transferred_death_records
      @death_record = @transferred_death_records.select{ |record| record.id.to_s == params[:death_record_id].to_s }.first
    end
  end

  # Retrieve all DeathRecords created by this user (that aren't currently
  # owned by this user).
  def set_transferred_death_records
    transferred = []
    current_user.step_histories.each do |history|
      transferred.push(history.death_record)
    end
    @transferred_death_records = transferred - current_user.owned_death_records
  end

  def comment_params
    params.permit(:content, :death_record_id, :requested_edits)
  end
end
