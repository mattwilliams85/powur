module Phone
  extend ActiveSupport::Concern

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
