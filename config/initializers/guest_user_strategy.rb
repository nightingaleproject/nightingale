Warden::Strategies.add(:guest_user) do
  def valid?
    !params[:guest_user_token].nil?
  end

  def authenticate!
    # Check if token is expired and user is legitimate.
    user_token = UserToken.where(token: params[:guest_user_token]).first
    if !user_token.present? || user_token.login_token_expired?
      fail!
    else
      user = User.where(id: user_token.user_id).first
      success!(user) if user.present?
    end
  end
end