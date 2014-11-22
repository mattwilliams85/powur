class QualificationsJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :qualifications, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :qualificattion

    entity_rel(rel) if rel
  end

  def properties(qualification = @item)
    json.properties do
      json.type qualification.type_string
      json.call(qualification, :id, :type_display,
                :path, :time_period, :quantity, :product_id)
      if qualification.is_a?(GroupSalesQualification)
        json.max_leg_percent qualification.max_leg_percent
      end
      json.product qualification.product.name
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :qualification
  end

  def create_action(path)
    product_ref = { type: :link, rel: :products, value: :id, name: :name }
    action(:create, :post, path)
      .field(:rank_path_id, :select,
             options:  Hash[all_paths.map { |p| [ p.id, p.name ] }])
      .field(:type, :select,
             options: Qualification::TYPES, value: :sales)
      .field(:product_id, :select, reference:  product_ref)
      .field(:time_period, :select,
             options: Qualification.enum_options(:time_periods),
             value:   :monthly)
      .field(:quantity, :number)
      .field(:max_leg_percent, :number,
             visibility: { control: :type, values: [ :group_sales ] })
  end

  def update_action(path, qual)
    action = action(:update, :patch, path)
      .field(:rank_path_id, :select,
             options: Hash[all_paths.map { |p| [ p.id, p.name ] }],
             value:   qual.rank_path_id)
      .field(:time_period, :select,
             options: Qualification.enum_options(:time_periods),
             value:   qual.time_period)
      .field(:quantity, :number, value: qual.quantity)
    if qual.is_a?(GroupSalesQualification)
      action.field(:max_leg_percent,
                   :number, value: qual.max_leg_percent)
    end
    action
  end

  def delete_action(path)
    action(:delete, :delete, path)
  end

  def item(path, qual)
    klass :qualification

    properties(qual)

    actions update_action(path, qual), delete_action(path)

    self_link path
  end
end
