require 'eyecue_ipayout/client'
require 'eyecue_ipayout/config'
require 'eyecue_ipayout/service'
require 'eyecue_ipayout/service_param'
module EyecueIpayout
  extend Config
  class << self
    # Alias for EyecueIpayout::Client.new
    #
    # @return [EyecueIpayout::Client]
    def new
      EyecueIpayout::Client.new
    end

    # Delegate to EyecueIpayout::Client
    def method_missing(method, *args, &block)
      return super unless new.respond_to?(method)
      new.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      new.respond_to?(method, include_private) || super(method, include_private)
    end
  end
end
