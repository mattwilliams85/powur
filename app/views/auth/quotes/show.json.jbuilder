siren json

json.partial! 'item', quote: @quote

json.properties do
  json.call(@quote.customer, :email, :phone, :address, :city, :state, :zip)
  json.product_fields @quote.data.each { |key, value| json.set! key, value }
end

if @quote.last_update
  entities entity('auth/lead_updates/item', 'quote-update',
                  lead_update: @quote.last_update)
end

if @quote.submitted_at?

  actions(quotes_json.auth_actions(@quote))

else
  path = quote_path(@quote)

  update = action(:update, :patch, path)
    .field(:first_name, :text, value: @quote.customer.first_name)
    .field(:last_name, :text, value: @quote.customer.last_name)
    .field(:email, :email, required: false, value: @quote.customer.email)
    .field(:phone, :text, required: false, value: @quote.customer.phone)
    .field(:address, :text, required: false, value: @quote.customer.address)
    .field(:city, :text, required: false, value: @quote.customer.city)
    .field(:state, :text, required: false, value: @quote.customer.state)
    .field(:zip, :text, required: false, value: @quote.customer.zip)

  quotes_json.action_quote_fields(update) do |field, opts|
    opts.merge!(
      value:         field.normalize(@quote.data[field.name]),
      product_field: true)
  end

  actions(quotes_json.auth_actions(@quote))

end