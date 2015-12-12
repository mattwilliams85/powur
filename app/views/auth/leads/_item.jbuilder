klass :lead

entity_rel(local_assigns[:rel] || 'item')

json.properties do
  json.call(lead, :id, :data_status, :sales_status, :invite_status,
            :submitted_at, :provider_uid, :created_at, :action_badge,
            :first_name, :last_name, :email, :phone, :code,
            :address, :city, :state, :notes, :last_viewed_at, :updated_at)
  json.call(lead, :action_copy, :completion_chance) if lead.lead_action?
  [ :converted_at, :closed_won_at,
    :contracted_at, :installed_at ].each do |key_date|
    json.set! key_date, lead.send(key_date)
  end
  json.average_bill lead.data['average_bill']
  json.stage lead.lead_stage
  json.user lead.user.full_name
  json.product lead.product.name
end

actions = []
actions << action(:update, :patch, lead_path(lead))
  .field(:first_name, :text, value: lead.first_name)
  .field(:last_name, :text, value: lead.last_name)
  .field(:email, :email, value: lead.email)
  .field(:phone, :text, value: lead.phone)
  .field(:address, :text, value: lead.address)
  .field(:city, :text, value: lead.city)
  .field(:state, :text, value: lead.state)
  .field(:zip, :text, value: lead.zip)
  .field(:notes, :text, required: false, value: lead.notes)
actions << action(:resend, :post, resend_lead_path(lead))
actions << action(:delete, :delete, lead_path(lead))

actions(*actions) if !lead.submitted?

entity_list = []
entity_list << entity(%w(email),
                       'invite-email',
                       email_product_invite_path(lead.customer.id)) if lead.customer

self_link lead_path(lead)
