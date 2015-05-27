klass :enrollment

entity_rel('item')

json.properties do
  json.call(enrollment, :state, :product_id)
end
