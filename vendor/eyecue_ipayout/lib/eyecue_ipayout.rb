require 'eyecue_ipayout/client'
require 'eyecue_ipayout/config'
require 'eyecue_ipayout/configuration'
require 'eyecue_ipayout/service'
require 'eyecue_ipayout/service_param'

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

  # if ENV['IPAYOUT_API_ENDPOINT']
  #   self.endpoint = ENV['IPAYOUT_API_ENDPOINT']
  # end

  # if ENV['IPAYOUT_MERCHANT_PASSWORD']
  #   self.merchant_password = ENV['IPAYOUT_MERCHANT_PASSWORD']
  # end

  # if ENV['IPAYOUT_MERCHANT_GUID']
  #   self.merchant_guid = ENV['IPAYOUT_MERCHANT_GUID']
  # end
end
