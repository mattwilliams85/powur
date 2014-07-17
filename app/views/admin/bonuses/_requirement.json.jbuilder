klass :requirement

json.rel [ :item ]

json.properties do
  json.(requirement, :id, :quantity, :source)
  json.product requirement.product.name
end

actions \
  action(:update, :patch, bonus_requirement_path(requirement.bonus, requirement)).
    field(:product_id, :select, 
      reference:  { type: :link, rel: :products, value: :id, name: :name }, 
      value: requirement.product_id).
    field(:quantity, :number, value: requirement.quantity).
    field(:source, :checkbox, value: requirement.source),
  action(:delete, :delete, bonus_requirement_path(requirement.bonus, requirement))

links \
  link(:products, products_path)

