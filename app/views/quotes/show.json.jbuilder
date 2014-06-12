siren json

klass :quote

json.properties do
  json.(@customer, :email, :first_name, :last_name, :phone, :address, :city, :state, :zip, :roof_material, :roof_age)
end

actions \
  action(:update, :patch, quote_path).
    field(:quote, :hidden, value: @customer.url_slug).
    field(:email, :email, value: @customer.email).
    field(:first_name, :text, value: @customer.first_name).
    field(:last_name, :text, value: @customer.last_name).
    field(:phone, :text, value: @customer.phone).
    field(:address, :text, value: @customer.address).
    field(:city, :text, value: @customer.city).
    field(:state, :email, value: @customer.state).
    field(:zip, :text, value: @customer.zip).
    field(:roof_material, :text, value: @customer.roof_material).
    field(:roof_age, :number, value: @customer.roof_age)

links \
  link(:self, customer_quote_path(@promoter.url_slug, @customer.url_slug))