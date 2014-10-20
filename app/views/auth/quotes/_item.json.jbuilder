klass :quote

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(quote, :id, :data_status)
  json.call(quote.customer, :first_name, :last_name, :full_name)
end

links \
  link :self, user_quote_path(quote)
