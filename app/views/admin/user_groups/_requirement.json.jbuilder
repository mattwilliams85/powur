klass :requirement

entity_rel('item')

json.properties do
  json.call(requirement, :id, :event_type, :quantity)
  json.product requirement.product.name
end

actions action(:delete, :delete, user_group_requirement_path(requirement)),
        action(:update, :patch, user_group_requirement_path(requirement))
          .field(:product_id, :select,
                 options:  Hash[all_products.map { |p| [ p.id, p.name ] }],
                 required: true,
                 value:    requirement.product_id)
          .field(:event_type, :select,
                 options: UserGroupRequirement.enum_options(:event_types),
                 value:   requirement.event_type)
          .field(:quantity, :number, value: requirement.quantity)

self_link user_group_requirement_path(requirement)
