module Errors
  class AlertError < StandardError
    def as_json
      { error: {
        type:    :alert,
        message: message } }
    end
  end
end
