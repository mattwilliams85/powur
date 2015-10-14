module Errors
  class InputError < StandardError
    attr_reader :input, :attrs

    def initialize(input, attrs = {})
      @input = input
      @attrs = attrs
    end

    def as_json
      { error: { type: :input, message: message, input: input }.merge(attrs) }
    end
  end
end
