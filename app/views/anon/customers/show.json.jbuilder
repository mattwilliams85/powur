siren json

klass :lead

json.properties do
  json.first_name @lead.first_name
  json.last_name @lead.last_name
  json.user_id @lead.user_id
  json.sponsor @lead.user.full_name
end

actions_list = [
  action(:validate_zip, :post, zip_validator_path)
    .field(:zip, :text)
    .field(:code, :text, value: @lead.code),
  action(:submit_lead, :put, lead_path(@lead.code))
    .field(:first_name, :text, value: @lead.first_name)
    .field(:last_name, :text, value: @lead.last_name)
    .field(:email, :email, value: @lead.email)
    .field(:phone, :text, value: @lead.phone)
    .field(:address, :text, value: @lead.address)
    .field(:city, :text, value: @lead.city)
    .field(:state, :text, value: @lead.state)
    .field(:zip, :text, value: @lead.zip)
    .field(:average_bill, :text) ]

actions(*actions_list)
