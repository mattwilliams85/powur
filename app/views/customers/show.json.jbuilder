siren json

json.partial! 'item', user: @customer, detail: true

json.properties do
  json.(@customer, :phone, :address, :city, :state, :zip, :kwh)
end

actions \
  action(:update, :patch, customer_path(@customer)).
    field(:first_name, :text, value: @customer.first_name).
    field(:last_name, :text, value: @customer.last_name).
    field(:email, :email, required: false, value: @customer.email).
    field(:phone, :text, required: false, value: @customer.phone).
    field(:address, :text, required: false, value: @customer.address).
    field(:city, :text, required: false, value: @customer.city).
    field(:state, :text, required: false, value: @customer.state).
    field(:zip, :text, required: false, value: @customer.zip).
    field(:kwh, :number, required: false, value: @customer.kwh)

links \
  link(:self, customer_path(@customer))