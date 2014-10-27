class AuthController < ApplicationController
  before_action :authenticate!

  def authenticate!
    redirect_to(root_url) unless logged_in?
  end

  def fetch_downline_user(user_id)
    return current_user if user_id == current_user.id
    User.with_ancestor(user_id).where(id: user_id).first ||
      not_found!(:user, user_id)
  end
end
