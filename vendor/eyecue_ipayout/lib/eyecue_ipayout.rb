require 'eyecue_ipayout/client'
require 'eyecue_ipayout/config'
require 'eyecue_ipayout/configuration'
require 'eyecue_ipayout/service'
require 'eyecue_ipayout/service_param'
require 'byebug'
module EyecueIpayout
  extend Config
  class << self
    attr_accessor :configuration

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

  def self.reset
    @configuration = Configuration.new
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
