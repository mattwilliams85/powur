klass :lead

entity_rel(local_assigns[:rel] || 'item')

json.properties do
  json.call(lead, :id, :data_status, :sales_status,
            :submitted_at, :provider_uid, :created_at)
  json.user lead.user.full_name
  json.customer_id lead.customer.id
  json.customer lead.customer.full_name
  json.product lead.product.name
end

self_link lead_path(lead)
