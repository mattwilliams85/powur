siren json

klass :customer

json.properties do
  json.first_name @customer.first_name
end

actions_list = [
  action(:validate_zip, :post, zip_validator_path)
    .field(:zip, :text)
    .field(:code, :text, value: @customer.code) ]

actions(*actions_list)
