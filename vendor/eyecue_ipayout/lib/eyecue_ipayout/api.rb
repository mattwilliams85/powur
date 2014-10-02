require 'eyecue_ipayout/config'
require 'eyecue_ipayout/connection'

module EyecueIpayout
  class API
    include Connection
    include Request

    attr_accessor *Config::VALID_OPTIONS_KEYS
    # Creates a new API
    def initialize(options={})
      options = EyecueIpayout.options.merge(options)
      Config::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
      
    end
  end
end
