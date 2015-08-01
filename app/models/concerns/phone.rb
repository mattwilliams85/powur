module Phone
  extend ActiveSupport::Concern

  def twilio_enabled?
    ENV['TWILIO_ENABLED'] == '1'
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new
  end

  def twilio_lookups_client
    @twilio_lookups_client ||= Twilio::REST::LookupsClient.new
  end

  def valid_phone?(phone)
    return false unless phone
    response = twilio_lookups_client.phone_numbers.get(phone)
    return response.phone_number
  rescue => e
    return false if e.code == 20_404 # Resource not found Twilio error code
    raise e
  end

  def send_sms(to, body)
    return unless twilio_enabled? && to.present? && try(:allow_sms) != 'false'
    twilio_client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
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