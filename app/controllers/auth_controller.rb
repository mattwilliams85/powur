class AuthController < WebController
  before_action :authenticate!
  before_action :verify_terms_acceptance

  protected

  def authenticate!
    return true if logged_in?
    unauthorized!(root_url)
  end

  def verify_admin
    return true if admin?
    unauthorized!(dashboard_url)
  end

  def verify_terms_acceptance
    return true if current_user.accepted_latest_terms?
    unauthorized!(dashboard_url)
  end

  def fetch_user
    return nil unless user_id_param?
    not_found!(:user, user_id) if user_id == 0
    @user = admin? ? User.find(user_id) : fetch_downline_user(user_id)
  end

  # force selected user to current user if none requested in url
  # and current user is not an admin
  def fetch_user!
    fetch_user.nil? && !admin? && (@user = current_user)
  end

  def unauthorized!(url)
    json_request = request.xhr? || request.format.json?
    json_request ? head(:unauthorized) : redirect_to(url)
  end

  private

  def fetch_downline_user(user_id)
    return current_user if user_id == current_user.id
    User
      .with_ancestor(current_user.id)
      .where(id: user_id.to_i).first || not_found!(:user, user_id)
  end
  
  def user_id_param?
    # %w(user_id admin_user_id) & params.keys
    params.keys.include?('user_id') || params.keys.include?('admin_user_id')
  end

  def user_id
    (params[:user_id] || params[:admin_user_id]).to_i
  end
end
