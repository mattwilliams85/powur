class TwilioClient
  attr_reader :client

  def initialize(*args)
    @client = Twilio::REST::Client.new(*args)
  end

  def account
    @account ||= client.account
  end

  def purchased_numbers(opts = {})
    @purchased_numbers ||= account.incoming_phone_numbers.list(opts)
      .map(&:phone_number)
  end

  def send_message(*args)
    client.messages.create(*args)
  end

  def messages(*args)
    client.messages.list(*args)
  end

  # Send sms to provided recepient list
  # equaly distributing with all available purchased phone numbers
  def send_sms_in_groups(recipient_numbers, body)
    sent_messages = []
    recipient_numbers.in_groups_of(purchased_numbers.length) do |group|
      group.compact.each_index do |i|
        sent_messages << send_message(
          to:   group[i],
          from: purchased_numbers[i],
          body: body)
      end
      # TODO: remove the delay once 'short phone number' is purchased
      # Twilio 'long phone numbers' have a limitation of
      # one sms per second per phone
      sleep 2
    end
    sent_messages
  end
end
