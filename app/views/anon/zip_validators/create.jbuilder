siren json

klass :zip_validator

json.properties do
  json.is_valid @is_valid
end

actions_list = []

if @customer
  actions_list.push(
    action(:solar_invite, :put, product_invite_path(@customer.code))
      .field(:first_name, :text, value: @customer.first_name)
      .field(:last_name, :text, value: @customer.last_name)
      .field(:email, :email)
      .field(:phone, :text)
      .field(:address, :text)
      .field(:city, :text)
      .field(:state, :text)
      .field(:zip, :text)
      .field(:average_bill, :text))
end

actions(*actions_list)
