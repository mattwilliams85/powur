klass :lead

entity_rel(local_assigns[:rel] || 'item')

json.properties do
  json.call(lead, :id, :data_status, :sales_status,
            :submitted_at, :provider_uid, :created_at, :action_badge,
            :first_name, :last_name, :email, :phone,
            :address, :city, :state, :notes)
  json.call(lead, :action_copy, :completion_chance) if lead.lead_action?
  [ :converted_at, :closed_won_at,
    :contracted_at, :installed_at ].each do |key_date|
    json.set! key_date, lead.send(key_date)
  end
  json.average_bill lead.data['average_bill']
  json.user lead.user.full_name
  json.customer do
    json.call(lead.customer,
              :id, :status, :first_name, :last_name, :email, :phone,
              :full_address, :city, :state,
              :notes, :last_viewed_at, :updated_at)
  end if lead.customer
  json.product lead.product.name
end

actions = []
actions << action(:update, :patch, product_invite_path(lead.customer))
  .field(:first_name, :text, value: lead.customer.first_name)
  .field(:last_name, :text, value: lead.customer.last_name)
  .field(:email, :email, value: lead.customer.email)
  .field(:phone, :text, value: lead.customer.phone)
  .field(:address, :text, value: lead.customer.address)
  .field(:city, :text, value: lead.customer.city)
  .field(:state, :text, value: lead.customer.state)
  .field(:zip, :text, value: lead.customer.zip)
actions << action(:resend, :post, resend_product_invite_path(lead.customer))
actions << action(:delete, :delete, product_invite_path(lead.customer))

actions(*actions) if !lead.submitted?

entity_list = [ entity(%w(email),
                       'invite-email',
                       email_product_invite_path(lead.customer.id)) ]

self_link lead_path(lead)
