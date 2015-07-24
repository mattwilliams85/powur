klass :enrollment
json.rel [ 'enrollment' ]
json.properties do
  json.call(enrollment, :state, :product_id)
end
