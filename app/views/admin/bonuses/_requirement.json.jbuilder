klass :requirement

json.rel [ :item ]

json.properties do
  json.call(requirement, :quantity, :source)
  json.product_id requirement.product_id
  json.product requirement.product.name
end

req_path = bonus_requirement_path(requirement.bonus, requirement.product_id)

update_action = action(:update, :patch, req_path)
                .field(:quantity, :number, value: requirement.quantity)
if requirement.source_modifiable?
  update_action.field(:source, :checkbox, value: requirement.source)
end

actions update_action, action(:delete, :delete, req_path)

links link(:products, products_path)
