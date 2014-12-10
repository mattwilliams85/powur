class ApiController < ApplicationController
  include ListQuery
  include SirenDSL
  helper SirenJson

  before_action :authenticate!

  rescue_from Exception, with: :server_error
  rescue_from Errors::ApiError, with: :error_response

  protected

  def error!(error, msg)
    fail Errors::ApiError.new(error), msg
  end

  def expect_params(*args)
    missing = args.select { |arg| !params[arg].present? }
    return params.permit(*args) if missing.empty?
    msg = "missing the following required params: \"#{missing.join(', ')}\""
    error!(:invalid_request, msg)
  end

  private

  def bearer_auth_header
    return nil if request.authorization.nil?
    parts = request.authorization.split(' ')
    return nil unless parts.first == 'Bearer'
    parts.last
  end

  def bearer_parameter
    params[:access_token]
  end

  def access_token_param
    bearer_auth_header || bearer_parameter
  end

  def access_token
    @access_token ||= ApiToken.find_by(access_token: access_token_param)
  end

  def valid_token?
    !access_token.nil?
  end

  def token_expired?
    access_token.expired?
  end

  def current_user
    @current_user ||= access_token.user
  end

  def authenticate!
    error!(:invalid_token, 'access_token is invalid') unless valid_token?
    error!(:invalid_grant, 'access_token is expired') if token_expired?
  end

  def server_error(e)
    error!(:server_error, e.message)
  rescue Errors::ApiError => ex
    unless Rails.env.production?
      ex.backtrace = e.backtrace
      ex.error_klass = e.class.name
    end
    error_response(ex)
  end

  def error_response(e)
    response.status = e.status
    render json: e.to_h
  end
end
