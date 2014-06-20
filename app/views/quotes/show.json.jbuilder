siren json

klass :quote

json.properties do
  json.(@quote.customer, :email, :first_name, :last_name, :phone, :address, :city, :state, :zip)
  @quote.data.each do |key,value|
    json.set! key, value
  end
end

update_action = action(:update, :patch, quote_path).
  field(:quote, :hidden, value: @quote.url_slug).
  field(:email, :email, value: @quote.customer.email).
  field(:first_name, :text, value: @quote.customer.first_name).
  field(:last_name, :text, value: @quote.customer.last_name).
  field(:phone, :text, value: @quote.customer.phone).
  field(:address, :text, value: @quote.customer.address).
  field(:city, :text, value: @quote.customer.city).
  field(:state, :email, value: @quote.customer.state).
  field(:zip, :text, value: @quote.customer.zip)

@quote.data.each do |key, value|
  update_action.field(key, :text, required: false, value: value)
end

actions update_action

links \
  link(:self, customer_quote_path(@quote.user.url_slug, @quote.url_slug))