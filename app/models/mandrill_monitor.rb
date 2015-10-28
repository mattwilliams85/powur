require 'mandrill'

class MandrillMonitor
  attr_reader :client, :email, :tag

  def initialize(opts = {})
    @client = Mandrill::API.new(ENV['MANDRILL_API_KEY'])
    @email = opts[:email]
    @tag = opts[:tag]
  end

  # Returns a mandrill message object data
  def message
    @message ||=
      client.messages.search("email:'#{email}' AND tags:'#{tag}'").first
  end

  def opened?
    message['opens'] > 0
  end

  def clicked?
    message['clicks'] > 0
  end
end
