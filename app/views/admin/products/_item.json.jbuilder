klass :product

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(product,
            :id, :name, :bonus_volume,
            :commission_percentage, :prerequisite_id)
end

links link(:self, product_path(product))
