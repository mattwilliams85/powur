class TwilioClient
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new
  end

  def account
    @account ||= client.account
  end

  def purchased_numbers(opts = {})
    @purchased_numbers ||= account.incoming_phone_numbers.list(opts)
      .map(&:phone_number)
  end

  # Send sms to provided recepient list
  # equaly distributing with all available purchased phone numbers
  def send_sms_in_groups(recipient_numbers, body)
    recipient_numbers.in_groups_of(purchased_numbers.length) do |group|
      group.compact.each_index do |i|
        client.messages.create(
          to:   group[i],
          from: purchased_numbers[i],
          body: body)
      end
      # TODO: remove the delay once 'short phone number' is purchased
      # Twilio 'long phone numbers' have a limitation of
      # one sms per second per phone
      sleep 2
    end
  end
end
