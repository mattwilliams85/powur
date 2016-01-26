  class IntegrationError < StandardError
    attr_reader :error

    def initialize(error)
      @error = error
    end
  end
