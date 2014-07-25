klass :requirement

json.rel [ :item ]

json.properties do
  json.(requirement, :quantity)
  json.product requirement.product.name
end

actions \
  action(:update, :patch, bonus_requirement_path(requirement.bonus, requirement.product_id)).
    field(:product_id, :select, 
      reference:  { type: :link, rel: :products, value: :id, name: :name }, 
      value: requirement.product_id).
    field(:quantity, :number, value: requirement.quantity),
  action(:delete, :delete, bonus_requirement_path(requirement.bonus, requirement.product_id))

links \
  link(:products, products_path)

