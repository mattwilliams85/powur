class ApplicationController < ActionController::Base
  include ParamValidation
  protect_from_forgery with: :exception
  helper_method :current_user

  def redirect_to(*args)
    if request.xhr?
      render json: { redirect: args.first }, status: :ok
    else
      super
    end
  end

  def current_user
    @current_user ||= session[:user_id] && User.find(session[:user_id].to_i)
  end

  def logged_in?
    !!current_user
  end
end
