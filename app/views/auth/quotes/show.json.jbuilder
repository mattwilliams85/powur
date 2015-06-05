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

path = quote_path(@quote)
resend = action(:resend, :post, path)

if @quote.submitted_at?
  actions(resend)
else
  update = action(:update, :patch, path)
    .field(:first_name, :text, value: @quote.customer.first_name)
    .field(:last_name, :text, value: @quote.customer.last_name)
    .field(:email, :email, required: false, value: @quote.customer.email)
    .field(:phone, :text, required: false, value: @quote.customer.phone)
    .field(:address, :text, required: false, value: @quote.customer.address)
    .field(:city, :text, required: false, value: @quote.customer.city)
    .field(:state, :text, required: false, value: @quote.customer.state)
    .field(:zip, :text, required: false, value: @quote.customer.zip)

  @quote.product.quote_fields.each do |field|
    opts = {
      required:      field.required,
      product_field: true,
      value:         field.normalize(@quote.data[field.name]) }

    if field.lookup?
      lookups = field.lookups.sort_by { |i| [ i.group, i.value ] }
      next if lookups.empty?
      opts[:options] = lookups.map do |lookup|
        attrs = { display: lookup.value }
        attrs[:group] = lookup.group if lookup.group
        attrs
      end
    end

    update.field(field.name, field.view_type, opts)
  end

  list = [ resend, update, action(:delete, :delete, path) ]
  if @quote.can_submit?
    list << action(:submit, :post, submit_quote_path(@quote))
  end

  actions(*list)
end
