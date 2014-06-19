siren json

json.partial! 'item', quote: @quote, detail: true

json.properties do
  json.(@quote.customer, :email, :phone, :address, :city, :state, :zip)
  @quote.data.each do |key,value|
    json.set! key, value
  end
end

update_action = action(:update, :patch, user_quote_path(@quote)).
  field(:first_name, :text, value: @quote.customer.first_name).
  field(:last_name, :text, value: @quote.customer.last_name).
  field(:email, :email, required: false, value: @quote.customer.email).
  field(:phone, :text, required: false, value: @quote.customer.phone).
  field(:address, :text, required: false, value: @quote.customer.address).
  field(:city, :text, required: false, value: @quote.customer.city).
  field(:state, :text, required: false, value: @quote.customer.state).
  field(:zip, :text, required: false, value: @quote.customer.zip)

@quote.data.each do |key, value|
  update_action.field(key, :text, required: false, value: value)
end

actions \
  update_action,
  action(:resend, :post, resend_user_quote(@quote))
