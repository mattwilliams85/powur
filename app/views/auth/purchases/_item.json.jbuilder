klass :purchase
json.rel [ 'purchase' ]
json.properties do
  json.call(purchase, :product_id)
end
