klass :quote_field

json.rel [ 'product-quote_field' ]

json.properties do
  json.call(quote_field, :id, :name, :data_type, :required)

  if quote_field.lookup?
    json.lookups quote_field.lookups, :identifier, :value
  end
end
