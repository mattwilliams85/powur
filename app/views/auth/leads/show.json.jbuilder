siren json

json.partial! 'item', lead: @lead

json.properties do
  json.call(@lead.customer, :email, :phone,
            :address, :city, :state, :zip, :notes)
  json.product_fields @lead.data.each { |key, value| json.set! key, value }
end

if @lead.last_update
  entities entity('auth/lead_updates/item', 'lead-update',
                  lead_update: @lead.last_update)
end

path = lead_path(@lead)
resend = action(:resend, :post, resend_lead_path(@lead))

if @lead.submitted_at?
  actions(resend)
else
  update = action(:update, :patch, path)
    .field(:first_name, :text, value: @lead.customer.first_name)
    .field(:last_name, :text, value: @lead.customer.last_name)
    .field(:email, :email, required: false, value: @lead.customer.email)
    .field(:phone, :text, required: false, value: @lead.customer.phone)
    .field(:address, :text, required: false, value: @lead.customer.address)
    .field(:city, :text, required: false, value: @lead.customer.city)
    .field(:state, :text, required: false, value: @lead.customer.state)
    .field(:zip, :text, required: false, value: @lead.customer.zip)
    .field(:notes, :text, required: false, value: @lead.customer.notes)

  @lead.product.quote_fields.each do |field|
    opts = {
      required:      field.required,
      product_field: true,
      value:         field.normalize(@lead.data[field.name]) }

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
  if @lead.ready_to_submit?
    list << action(:submit, :post, submit_lead_path(@lead))
  end

  actions(*list)
end
