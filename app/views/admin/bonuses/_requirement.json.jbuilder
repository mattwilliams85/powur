klass :requirement

json.rel [ :item ]

json.properties do
  json.(requirement, :quantity, :source)
  json.product_id requirement.product_id
  json.product requirement.product.name
end

actions \
  action(:update, :patch, bonus_requirement_path(requirement.bonus, requirement.product_id)).
    field(:quantity, :number, value: requirement.quantity).
    field(:source, :checkbox, value: requirement.source),
  action(:delete, :delete, bonus_requirement_path(requirement.bonus, requirement.product_id))

links \
  link(:products, products_path)

