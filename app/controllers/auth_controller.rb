class AuthController < WebController
  before_action :authenticate!

  def authenticate!
    redirect_to(root_url) unless logged_in?
  end
end
