siren json

klass :requirements, :list

json.entities @requirements, partial: 'item', as: :requirement

self_path = user_group_requirements_path(@user_group)

if admin?
  create = action(:create, :post, self_path)
  create.field(:event_type, :select,
               options: UserGroupRequirement.enum_options(:event_types),
               require: true)
  create.field(:product_id, :select,
               options:  Hash[all_products.map { |p| [ p.id, p.name ] }],
               required: true)
  actions(create)
end

self_link self_path
