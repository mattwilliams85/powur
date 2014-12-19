class EarningsJson < JsonDecorator

  def list_init(partial_path = 'item')
    klass :earnings, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :earnings

    entity_rel(rel) if rel
  end

  def list_item_properties(earning = @item)
    json.properties do
      json.call(earning, :id, :pay_period_id, :amount, :user_id)
      #json.pay_period earning.pay_period
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :earning
  end
end
