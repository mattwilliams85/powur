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

  def sign_in_expired?
    # HACKFIX, need better way to mock user session for test
    current_user.sign_in_expired?(session[:expires_at]) && !Rails.env.test?
  end

  def logged_in?
    return false unless current_user
    
    if sign_in_expired? || current_user.terminated?
      reset_session
      @current_user = nil
      return false
    end

    session[:expires_at] = Time.current + 1.hour
    true
  end

  def admin?
    current_user.role?(:admin)
  end

  def login_user(user, remember_me = nil)
    reset_session
    session[:user_id] = user.id
    session[:expires_at] = Time.current + 1.hour
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

  def user_from_session
    return session[:user] if session[:user]
    session[:user_id] && User.find_by(id: session[:user_id].to_i)
  end
end
