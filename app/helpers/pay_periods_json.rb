class PayPeriodsJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :pay_periods, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :pay_period

    entity_rel(rel) if rel
  end

  def list_item_properties(pay_period = @item)
    json.properties do
      json.call(pay_period, :id, :start_date, :end_date, :title)
      json.type pay_period.type_display
      json.calculated pay_period.calculated?
      json.disbursed pay_period.distributed?
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :pay_period
  end
end
