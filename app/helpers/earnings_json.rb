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
      json.call(earning, :amount)
      json.pay_period_title earning.pay_period.title
      json.pay_period_type earning.pay_period.type_display
      json.pay_period_date_range earning.pay_period.date_range_display('%m-%d')
      json.pay_period_week_number earning.pay_period.start_date.week_of_month
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :earning
  end

  def order_entities(partial_path, orders = @orders)
    json.entities orders, partial: partial_path, as: :order
  end

  def list_detail_properties(earning = @item)
    json.properties do
      json.call(earning, :id, :bonus_id, :amount, :user_id)
      json.pay_period earning.pay_period.type_display
      order_entities('order', earning.orders)
    end
  end

  def list_order_properties(order = @item)
    json.properties do
      json.call(order, :id, :order_date)
      json.customer order.customer.full_name
    end
  end

  def list_detail_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :earning_detail
  end
end
