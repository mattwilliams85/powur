module Errors
  class ApiError < StandardError
    attr_reader :error
    attr_accessor :error_klass, :backtrace

    UNAUTHORIZED = [ :invalid_client ]
    SERVER_ERRORS = [ :server_error ]

    def initialize(error, error_fields = {})
      @error = error
      if UNAUTHORIZED.include?(error)
        @status = :unauthorized
      elsif SERVER_ERRORS.include?(error)
        @status = :internal_server_error
      end
      @error_fields = error_fields
    end

    def status
      @status ||= :bad_request
    end

    def to_h
      hash = @error_fields.merge(error: error, error_description: message)
      hash[:backtrace] = backtrace unless backtrace.nil?
      hash[:error_klass] = error_klass unless error_klass.nil?
      hash
    end
  end
end
