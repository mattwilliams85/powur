siren json

klass :lead

json.properties do
  json.call(@lead, :email, :phone,
            :address, :city, :state, :zip, :notes, :last_viewed_at,
            :data_status, :sales_status, :invite_status)
  json.product_fields @lead.data.each { |key, value| json.set! key, value }
  json.owner do
    json.call(@lead.user, :id, :first_name, :last_name)
  end
end

actions_list = []

unless @lead.submitted_at?
  update = action(:update, :patch, lead_path(@lead.code))
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
end

actions(*actions_list)
