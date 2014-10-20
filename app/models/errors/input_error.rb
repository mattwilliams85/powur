module Errors
  class InputError < StandardError
    attr_reader :input

    def initialize(input)
      @input = input
    end

    def as_json
      { error: { type: :input, message: message, input: input } }
    end
  end
end
