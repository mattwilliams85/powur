class MandrillMonitor
  attr_reader :client, :parent, :message_id

  def initialize(parent)
    @client = Mandrill::API.new(ENV['MANDRILL_API_KEY'])
    @parent = parent
    @message_id = parent.mandrill_id
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

  private

  def message
    @message ||= client.messages.info(message_id)
  rescue Mandrill::UnknownMessageError
    parent.update_column(:mandrill_id, nil)
    @message = {}
  end
end
