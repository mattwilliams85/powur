siren json

klass :customer

json.properties do
  json.first_name @customer.first_name
  json.last_name @customer.last_name
  json.user_id @customer.user_id
end

actions_list = [
  action(:validate_zip, :post, zip_validator_path)
    .field(:zip, :text)
    .field(:code, :text, value: @customer.code),
  action(:submit_lead, :put, customer_path(@customer.code))
    .field(:first_name, :text, value: @customer.first_name)
    .field(:last_name, :text, value: @customer.last_name)
    .field(:email, :email, value: @customer.email)
    .field(:phone, :text, value: @customer.phone)
    .field(:address, :text, value: @customer.address)
    .field(:city, :text, value: @customer.city)
    .field(:state, :text, value: @customer.state)
    .field(:zip, :text, value: @customer.zip)
    .field(:average_bill, :text) ]

actions(*actions_list)
