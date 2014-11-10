module Errors
  class ApiError < StandardError
    attr_reader :error
    attr_accessor :error_klass, :backtrace

    UNAUTHORIZED = [ :invalid_client ]

    def initialize(error)
      @error = error
      @status = :unauthorized if UNAUTHORIZED.include?(error)
    end

    def status
      @status ||= :bad_request
    end

    def to_h
      hash = { error: error, error_description: message }
      hash[:backtrace] = backtrace unless backtrace.nil?
      hash[:error_klass] = error_klass unless error_klass.nil?
      hash
    end
  end
end
