class ApplicationController < ActionController::Base
  include ParamValidation
  include SirenDSL
  include ListQuery

  protect_from_forgery with: :exception
  helper_method :current_user

  def redirect_to(*args)
    respond_to do |format|
      format.json do
        render json: { redirect: args.first }, status: :ok
      end
      format.all { super }
    end
  end

  def current_user
    @current_user ||= session[:user_id] &&
      User.find_by(id: session[:user_id].to_i)
  end

  def logged_in?
    !current_user.nil?
  end

  def login_user(user)
    reset_session
    session[:user_id] = user.id
    @current_user = user
  end
end
