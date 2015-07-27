siren json

klass :twilio_phone_numbers, :list

json.entities @phone_numbers do |phone_number|
  json.properties do
    json.phone_number phone_number
    json.messages_sent @twilio_client
      .messages(from: phone_number, date_sent: Time.zone.today.to_s(:db)).length
  end
end
