class TwilioClient
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new(
      SystemSettings.get!('twilio_account_sid'),
      SystemSettings.get!('twilio_auth_token'))
  end

  def account
    @account ||= client.account
  end

  # Returns purchased phone numbers
  # Could be filtered by area code
  # Example: client.purchased_numbers(area_code: '760')
  def purchased_numbers(opts = {})
    area_code = opts.delete(:area_code)
    @purchased_numbers ||= account.incoming_phone_numbers.list(opts)
      .map(&:phone_number)
    return @purchased_numbers unless area_code

    # Area code filter
    exclude = false
    if area_code[0] == '!'
      exclude = true
      area_code.delete!('!')
    end
    @purchased_numbers.select do |n|
      exclude ? n[2..4] != area_code : n[2..4] == area_code
    end
  end

  def numbers_for_bulk_sms
    purchased_numbers(area_code: '760')
  end

  def numbers_for_personal_sms
    purchased_numbers(area_code: '!760')
  end

  def send_message(*args)
    client.messages.create(*args)
  end

  def messages(*args)
    client.messages.list(*args)
  end

  # Send sms to provided recepient list
  # equaly distributing through all available purchased phone numbers
  def send_sms_in_groups(recipient_numbers, body)
    sent_messages = []
    recipient_numbers.in_groups_of(purchased_numbers.length) do |group|
      group.compact.each_index do |i|
        begin
          sent_messages << send_message(
            to:   group[i],
            from: purchased_numbers[i],
            body: body)
        rescue Twilio::REST::RequestError => e
          Airbrake.notify(e)
          # Nullify phone number if it is invalid
          User.delay.nullify_phone_number!(group[i]) if e.code == 21211
        end
      end
      # TODO: remove the delay once 'short phone number' is purchased
      # Twilio 'long phone numbers' have a limitation of
      # one sms per second per phone
      sleep 2
    end
    sent_messages
  end
end
