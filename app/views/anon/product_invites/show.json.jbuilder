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
  action(:submit_lead, :put, product_invite_path(@customer.code))
    .field(:first_name, :text, value: @customer.first_name)
    .field(:last_name, :text, value: @customer.last_name)
    .field(:email, :email)
    .field(:phone, :text)
    .field(:address, :text)
    .field(:city, :text)
    .field(:state, :text)
    .field(:zip, :text, value: params['zip'])
    .field(:average_bill, :text) ]

actions(*actions_list)
