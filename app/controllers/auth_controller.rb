class AuthController < WebController
  before_action :authenticate!

  protected

  def authenticate!
    return true if logged_in?
    unauthorized!(root_url)
  end

  def verify_admin
    return true if admin?
    unauthorized!(dashboard_url)
  end

  def fetch_user
    user_id = (params[:user_id] || params[:admin_user_id]).to_i
    return unless user_id > 0
    @user = admin? ? User.find(user_id) : fetch_downline_user(user_id)
  end

  private

  def unauthorized!(url)
    request.xhr? ? head(:unauthorized) : redirect_to(url)
  end

  def fetch_downline_user(user_id)
    return current_user if user_id == current_user.id
    User.with_ancestor(current_user.id).where(id: user_id.to_i).first ||
      not_found!(:user, user_id)
  end
end
