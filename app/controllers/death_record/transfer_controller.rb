# Transfer Death Record Controller
class DeathRecord::TransferController < ApplicationController
  before_action :set_death_record

  def index
    # TODO: Add an authoize, user must own the record and must be a registrar or admin.
    # TODO: Or creator of the original document.
    @past_users = past_users
    @all_steps = WorkflowHelper.all_steps_for_given_record(@death_record)
  end

  def create
    # Currently previous_email is "email - role". So we need to grab just the email and pass that in to find the user id.
    new_owner = User.where(email: params[:Transfer][:previous_email].split.first).first

    # Use WorkflowHelper to adjust current and next steps.
    workflow_options = {}
    skip_normal_workflow = false

    workflow_options[:current_step] = WorkflowHelper.first_step_for_given_role_permission(Role.where(name: new_owner.roles.first.name).first, @death_record)

    # If checkbox is clicked. Then the value is 1.
    if params['Transfer']['send_back'] == '1'
      workflow_options[:next_step] = 'send_to_registrar'
      skip_normal_workflow = true
    end

    @death_record = WorkflowHelper.update_record_flow(@death_record, skip_normal_workflow, workflow_options)

    # Change death record owner to new owner
    @death_record.owner_id = new_owner.id
    @death_record.save!

    # Add comment containing the reason for the transfer and any notes to go along with the transfer.
    comment_content = params[:reason] + ': ' + params[:Transfer][:comment]
    comment = current_user.comments.create(content: comment_content, death_record_id: @death_record.id)
    comment.save!

    # Send Email.
    login_link = root_url
    if new_owner.is_guest_user
      guest_token = GuestUserHelper.generate_user_token(new_owner.id, @death_record.id)
      login_link = GuestUserHelper.generate_login_link(guest_token, root_url)
    end

    NotificationMailer.notification_email(new_owner, @death_record, comment, login_link).deliver_later
    redirect_to root_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_death_record
    @death_record = DeathRecord.find(params[:death_record_id])
  end

  # Creates list of users and their roles of who worked on this death record.
  def past_users
    historical_users = DeathRecordHistory.where(death_record_id: @death_record.id).distinct.pluck(:user_id)
    past_users = []
    historical_users.each do |user_id|
      if User.exists?(id: user_id) && current_user.id != user_id
        past_users << User.find(user_id).email + ' - ' + User.find(user_id).roles.first.name
      end
    end
    past_users
  end
end
