siren json

json.partial! 'auth/leads/item', lead: @lead

json.properties do
  json.call(@lead, :email, :phone,
            :address, :city, :state, :zip, :notes, :last_viewed_at,
            :data_status, :sales_status, :invite_status)
  json.product_fields @lead.data.each { |key, value| json.set! key, value }
  json.call(@lead, :action_copy, :completion_chance) if @lead.lead_action?
end

if @lead.last_update
  entities entity('auth/lead_updates/item', 'lead-update',
                  lead_update: @lead.last_update)
end

actions_list = [
  action(:resend, :post, resend_lead_path(@lead)) ]

unless @lead.submitted_at?
  update = action(:update, :patch, lead_path(@lead))
    .field(:first_name, :text, value: @lead.first_name)
    .field(:last_name, :text, value: @lead.last_name)
    .field(:email, :email, required: false, value: @lead.email)
    .field(:phone, :text, required: false, value: @lead.phone)
    .field(:address, :text, required: false, value: @lead.address)
    .field(:city, :text, required: false, value: @lead.city)
    .field(:state, :text, required: false, value: @lead.state)
    .field(:zip, :text, required: false, value: @lead.zip)
    .field(:notes, :text, required: false, value: @lead.notes)

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

  actions_list << update
  actions_list << action(:delete, :delete, lead_path(@lead))
  actions_list << action(:submit, :post, submit_lead_path(@lead))
end

actions(*actions_list)
