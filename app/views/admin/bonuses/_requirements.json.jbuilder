klass :requirements, :list

json.entities requirements, partial: 'requirement', as: :requirement

actions \
  action(:create, :post, bonus_requirements_path(bonus)).
    field(:product_id, :select, 
      reference:  { type: :link, rel: :products, value: :id, name: :name }).
    field(:quantity, :number, value: 1).
    field(:source, :checkbox, value: true)

links \
  link(:products, products_path)

