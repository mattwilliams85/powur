class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  def current_user
    @current_user ||= @current_user ||= session[:user_id] && 
      UserProfile.find(session[:user_id].to_i)
  end

  def logged_in?
    !!current_user
  end
end
