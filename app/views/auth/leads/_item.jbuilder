klass :lead

entity_rel(local_assigns[:rel] || 'item')

json.properties do
  json.call(lead, :id, :data_status, :sales_status, :invite_status,
            :submitted_at, :provider_uid, :created_at, :action_badge,
            :first_name, :last_name, :email, :phone, :code,
            :address, :city, :state, :zip, :notes, :call_consented,
            :last_viewed_at, :updated_at)
  json.call(lead, :action_copy, :completion_chance) if lead.lead_action?
  [ :converted_at, :closed_won_at,
    :contracted_at, :installed_at ].each do |key_date|
    json.set! key_date, lead.send(key_date)
  end
  json.average_bill lead.data['average_bill']
  json.stage lead.lead_stage
  json.product lead.product.name
  json.owner do
    json.call(lead.user, :id, :first_name, :last_name, :phone, :email)
    json.avatar do
      [ :thumb, :preview, :large ].each do |key|
        json.set! key, asset_path(lead.user.avatar.url(key))
      end
    end if lead.user.avatar?
  end
  json.getsolar_page_url(lead.getsolar_page_url)
end

actions_list = []

unless lead.submitted?
  update = action(:update, :patch, lead_path(lead))
    .field(:first_name, :text, value: lead.first_name)
    .field(:last_name, :text, value: lead.last_name)
    .field(:email, :email, required: false, value: lead.email)
    .field(:phone, :text, required: false, value: lead.phone)
    .field(:address, :text, required: false, value: lead.address)
    .field(:city, :text, required: false, value: lead.city)
    .field(:state, :text, required: false, value: lead.state)
    .field(:zip, :text, required: false, value: lead.zip)
    .field(:notes, :text, required: false, value: lead.notes)
    .field(:call_consented, :boolean,
           required: false, value: lead.call_consented)

  lead.product.quote_fields.each do |field|
    opts = {
      required:      field.required,
      product_field: true,
      value:         field.normalize(lead.data[field.name]) }

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
  actions_list << action(:resend, :post, resend_lead_path(lead))
  actions_list << action(:delete, :delete, lead_path(lead))
  if lead.ready_to_submit?
    actions_list << action(:submit, :post, submit_lead_path(lead))
  end
  if lead.not_sent?
    actions_list << action(:invite, :post, invite_lead_path(lead))
  end
  if current_user.admin?
    actions_list << action(:switch_owner, :patch, switch_owner_lead_path(lead))
      .field(:user_id, :number, value: lead.user_id)
  end
end

actions(*actions_list)

self_link lead_path(lead)
