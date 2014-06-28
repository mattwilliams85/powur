klass :product

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(product, :id, :name)
end

links \
  link :self, product_path(product)