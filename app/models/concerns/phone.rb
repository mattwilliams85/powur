module Phone
  extend ActiveSupport::Concern

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new
  end

  def twilio_lookups_client
    @twilio_lookups_client ||= Twilio::REST::LookupsClient.new
  end

  def valid_phone?(phone)
    response = twilio_lookups_client.phone_numbers.get(phone)
    return response.phone_number
  rescue => e
    return false if e.code == 20_404
    raise e
  end

  def send_sms(from, to, body)
    twilio_client.messages.create(
      from: from,
      to:   to,
      body: body
    )
  end

  class Validator < ActiveModel::Validator
    def validate(record)
      options[:fields].each do |field|
        unless record.valid_phone?(record.send(field))
          record.errors[field.to_sym] << 'Invalid phone number'
        end
      end
    end
  end
end
