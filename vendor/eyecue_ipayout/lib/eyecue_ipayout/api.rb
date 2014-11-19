require 'eyecue_ipayout/config'
require 'eyecue_ipayout/configuration'
require 'eyecue_ipayout/connection'
require 'eyecue_ipayout/service_param_map'

module EyecueIpayout
  class API
    include Connection

    attr_reader :service_param_map
    attr_accessor(*Config::VALID_OPTIONS_KEYS)
    # Creates a new API
    def initialize(options = {})
      options = EyecueIpayout.options.merge(options)
      @service_param_map = EyecueIpayout::ServiceParamMap.new
      Config::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end
  end
end
