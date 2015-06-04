klass :quote

entity_rel(local_assigns[:rel] || 'item')

json.properties do
  json.call(quote, :id, :status, :submitted_at, :provider_uid, :created_at)
  json.user quote.user.full_name
  json.customer_id quote.customer.id
  json.customer quote.customer.full_name
  json.product quote.product.name
end

self_link quote_path(quote)
