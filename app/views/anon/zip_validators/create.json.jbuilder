siren json

klass :zip_validator

json.properties do
  json.is_valid @is_valid
end

actions_list = []

if @is_valid
  actions_list.push(
    action(:solar_invite, :put, lead_path(@lead.code))
      .field(:user_id, :text, value: @lead.user_id)
      .field(:first_name, :text, value: @lead.first_name)
      .field(:last_name, :text, value: @lead.last_name)
      .field(:email, :email)
      .field(:phone, :text)
      .field(:address, :text)
      .field(:city, :text)
      .field(:state, :text)
      .field(:zip, :text, value: params['zip'])
      .field(:average_bill, :text))
end

actions(*actions_list)
