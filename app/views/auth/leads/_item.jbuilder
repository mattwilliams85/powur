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
  json.user lead.user.full_name
  json.customer do
    json.call(lead.customer,
              :id, :status, :first_name, :last_name, :email, :phone,
              :full_address, :city, :state,
              :notes, :last_viewed_at)
  end if lead.customer
  json.product lead.product.name
end

self_link lead_path(lead)
