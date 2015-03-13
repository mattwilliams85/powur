klass :requirements, :list

json.entities user_group.requirements,
              partial: 'admin/user_groups/requirement',
              as: :requirement

actions action(:create, :post, user_group_requirements_path(user_group.id))
          .field(:product_id, :select,
                 options:  Hash[all_products.map { |p| [ p.id, p.name ] }],
                 required: true)
          .field(:time_period, :select,
                 options: UserGroupRequirement.enum_options(:event_types),
                 required: true)
          .field(:quantity, :number, value: 1, required: true)
