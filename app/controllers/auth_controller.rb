class AuthController < WebController
  before_action :authenticate!

  def authenticate!
    return true if logged_in?
    if request.xhr?
      head :unauthorized
    else
      redirect_to(root_url)
    end
  end
end
