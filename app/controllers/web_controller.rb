class WebController < ApplicationController
  include ParamValidation
  include UserEvents

  protect_from_forgery with: :exception
  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def current_user
    @current_user ||= user_from_session
  end

  def logged_in?
    return false unless current_user

    if current_user.terminated?
      logout_user
      return false
    end

    true
  end

  def admin?
    current_user.role?(:admin)
  end

  def login_user(user, remember_me = nil)
    logout_user
    session[:user_id] = user.id
    if remember_me
      cookies.permanent.signed[:user_id] = {
        value:   user.id,
        expires: 10.days.from_now
      }
    end
    user.update_sign_in_timestamps!(remember_me)
    @current_user = user
    track_login_event(user)
  end

  def logout_user
    cookies.delete(:user_id)
    reset_session
    @current_user = nil
  end

  def redirect_to(*args)
    respond_to do |format|
      format.json do
        render json: { redirect: args.first }, status: :ok
      end
      format.all { super }
    end
  end

  def user_from_session
    return session[:user] if session[:user]
    user_id = session[:user_id] || cookies.signed[:user_id]
    user_id && User.find_by(id: user_id.to_i)
  end
end
