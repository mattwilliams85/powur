class AuthController < WebController
  before_action :authenticate!

  protected

  def authenticate!
    return true if logged_in?
    if request.xhr?
      head :unauthorized
    else
      redirect_to(root_path)
    end
  end


  def verify_admin
    return if admin?
    if request.xhr?
      head :unauthorized
    else
      redirect_to(dashboard_url)
    end
  end
end
