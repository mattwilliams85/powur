class GatewayController < ApplicationController
  protected

  def error!(error, msg)
    fail Errors::GatewayError.new(error), msg
  end

  def expect_params(*args)
    missing = args.select { |arg| !params[arg].present? }
    return params.permit(*args) if missing.empty?
    msg = "missing the following required params: \"#{missing.join(', ')}\""
    error!(:invalid_request, msg)
  end

  private

  def server_error(e)
    error!(:server_error, e.message)
  rescue Errors::GatewayError => ex
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
