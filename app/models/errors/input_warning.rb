module Errors
  class InputWarning < StandardError
    attr_reader :input, :attrs

    def initialize(input, attrs = {})
      @input = input
      @attrs = attrs
    end

    def as_json
      { warning: {
        type:    :input,
        message: message,
        input:   input }.merge(attrs) }
    end
  end
end
