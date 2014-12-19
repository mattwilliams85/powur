class WebController < ApplicationController
  include ParamValidation
  include UserEvents

  protect_from_forgery with: :exception

  def current_user
    @current_user ||= session[:user_id] && User.find_by(id: session[:user_id].to_i)
    if @current_user && @current_user.sign_in_expired?
      session[:user_id] = nil
      @current_user = nil
    end
    return @current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def login_user(user, remember_me=nil)
    reset_session
    session[:user_id] = user.id
    user.update_sign_in_timestamps!(remember_me)
    @current_user = user
    track_login_event(user)
  end

  def redirect_to(*args)
    respond_to do |format|
      format.json do
        render json: { redirect: args.first }, status: :ok
      end
      format.all { super }
    end
  end
end
