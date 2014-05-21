module Errors
  class AlertError < StandardError

    def as_json
      { error: { 
        type:     :alert, 
        message:  self.message } }
    end
  end
end