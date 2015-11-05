require 'mandrill'

class MandrillMonitor
  attr_reader :client, :message_id

  def initialize(message_id)
    @client = Mandrill::API.new(ENV['MANDRILL_API_KEY'])
    @message_id = message_id
  end

  # Returns a mandrill message object data
  def message
    @message ||= client.messages.info(message_id)
  end

  def opens
    message && message['opens']
  end

  def clicks
    message && message['clicks']
  end

  def state
    message && message['state']
  end
end
