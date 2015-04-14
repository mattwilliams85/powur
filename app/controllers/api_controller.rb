class ApiController < ApplicationController
  include ListQuery
  include SirenDSL
  helper SirenJson

  before_action :authenticate!

  rescue_from Exception, with: :server_error
  rescue_from Errors::ApiError, with: :error_response

  protected

  def api_error!(error, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    msg = if args.last.is_a?(String)
      args.pop
    else
      t(args.unshift('errors.api', error).join('.'), opts)
    end

    fail Errors::ApiError.new(error), msg
  end

  # def error!(error, msg)
  #   fail Errors::ApiError.new(error), msg
  # end

  def error!(msg, field = nil, opts = {})
    opts = field if field.is_a?(Hash)
    msg = t("errors.#{msg}", opts) if msg.is_a?(Symbol)
    args = field.is_a?(Symbol) ? { 'error_parameters' => [ field ] } : {}
    api_error!(:bad_request, msg, args)
  end

  def allow_input(*keys)
    Hash[params.permit(*keys).map { |k, v| [ k, v.presence ] }]
  end

  def require_input(*args)
    missing = args.select { |arg| !params[arg].present? }
    return params.permit(*args) if missing.empty?
    api_error!(:invalid_request, :missing_params, params: missing.join(','))
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
    api_error!(:invalid_token) unless valid_token?
    api_error!(:invalid_grant, :expired) if token_expired?
  end

  def server_error(e)
    api_error!(:server_error, e.message)
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
