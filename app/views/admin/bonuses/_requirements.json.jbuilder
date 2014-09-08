klass :requirements, :list

json.entities requirements, partial: 'requirement', as: :requirement

# TODO: default source based upon
# previously defined requirements

if bonus.can_add_requirement?
  create_action = action(:create, :post, bonus_requirements_path(bonus)).
    field(:product_id, :select, 
      reference:  { type: :link, rel: :products, value: :id, name: :name }).
    field(:quantity, :number, value: 1)

  unless bonus.solo_requirement?
    create_action.field(:source, :checkbox, value: true)
  end
  
  actions create_action
end

links link(:products, products_path)

