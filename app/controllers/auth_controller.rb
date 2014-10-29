class AuthController < ApplicationController
  before_action :authenticate!

  def authenticate!
    redirect_to(root_url) unless logged_in?
  end

  def fetch_downline_user(user_id)
    return current_user if user_id == current_user.id
    User.with_ancestor(current_user.id).where(id: user_id.to_i).first ||
      not_found!(:user, user_id)
  end
end
