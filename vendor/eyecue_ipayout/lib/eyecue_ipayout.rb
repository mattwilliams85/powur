require 'eyecue_ipayout/client'
require 'eyecue_ipayout/config'

module EyecueIpayout
  extend Config
  class << self

    # Alias for EyecueIpayout::Client.new
    #
    # @return [EyecueIpayout::Client]
    def new(options={})
      EyecueIpayout::Client.new(options)
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
