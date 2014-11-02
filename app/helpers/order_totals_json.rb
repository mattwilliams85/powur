class OrderTotalsJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :order_totals, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :order_total

    entity_rel(rel) if rel
  end

  def list_item_properties(totals = @item)
    json.properties do
      json.call(totals, :id, :pay_period_id, :product_id, :user_id, :personal, :group,
                :personal_lifetime, :group_lifetime)
      json.product totals.product.name
      json.distributor totals.user.full_name
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :order_total
  end
end
