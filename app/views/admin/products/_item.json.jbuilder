klass :product

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(product, :id, :name, :commissionable_volume, :commission_percentage)
end

links \
  link :self, product_path(product)