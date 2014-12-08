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

  def create_action(url_path, opts = {})
    opts[:paths] ||= all_paths
    action(:create, :post, url_path)
      .field(:rank_path_id, :select,
             options:  Hash[opts[:paths].map { |p| [ p.id, p.name ] }],
             required: false)
      .field(:type, :select,
             options: Qualification::TYPES, required: true, value: :sales)
      .field(:product_id, :select,
             options:  Hash[all_products.map { |p| [ p.id, p.name ] }],
             required: true)
      .field(:time_period, :select,
             options: Qualification.enum_options(:time_periods),
             value:   :monthly)
      .field(:quantity, :number)
      .field(:max_leg_percent, :number,
             visibility: { control: :type, values: [ :group_sales ] })
  end

  def rank_create_action(rank)
    url_path = rank_qualifications_path(rank)
    rank_paths = rank.first? ? all_paths.reject { |p| p.default? } : all_paths
    create_action(url_path, paths: rank_paths)
  end

  def update_action(path, qual)
    update = action(:update, :patch, path)
             .field(:rank_path_id, :select,
                    options:  Hash[all_paths.map { |p| [ p.id, p.name ] }],
                    required: true,
                    value:    qual.rank_path_id)
             .field(:type, :select,
                    options:  Qualification::TYPES,
                    required: true,
                    value:    qual.type)
             .field(:product_id, :select,
                    options:  Hash[all_products.map { |p| [ p.id, p.name ] }],
                    required: true,
                    value:    qual.product_id)
             .field(:time_period, :select,
                    options: Qualification.enum_options(:time_periods),
                    value:   qual.time_period)
             .field(:quantity, :number, value: qual.quantity)
    if qual.is_a?(GroupSalesQualification)
      update.field(:max_leg_percent,
                   :number, value: qual.max_leg_percent)
    end
    update
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
