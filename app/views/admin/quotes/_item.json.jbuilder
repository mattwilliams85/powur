klass :quote

entity_rel(local_assigns[:rel] || :item) unless local_assigns[:detail]

json.properties do
  json.(quote, :id, :data_status, :created_at)
  json.user quote.user.full_name
  json.customer quote.customer.full_name
  json.product quote.product.name
end

links link(:self, admin_quote_path(quote))