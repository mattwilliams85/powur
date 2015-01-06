class EarningsJson < JsonDecorator
  def list_detail_entities
    klass :earnings, :list
  end

  # summary
  def item_init(rel = nil)
    klass :earning_detail
    entity_rel(rel) if rel
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :earning_period
  end

  # earning periods are objects that contain pay_period
  # properties as well as aggregated amount totals from
  # bonus_payments (earnings)
  def list_earning_periods(partial_path, earning_periods)
    json.entities earning_periods, partial: partial_path, as: :earning_period
  end

  def earning_period_properties(earning_period)
    json.properties do
      json.user_id earning_period[:user_id]
    end

    list_pp_properties(earning_period[:pay_period])
    list_earning_properties(earning_period[:earning], earning_period[:user_id])
  end

  def list_pp_properties(pay_period)
    json.properties do
      json.pay_period_id pay_period.id
      json.pay_period_title pay_period.title
      json.pay_period_type pay_period.type_display
      json.pay_period_date_range pay_period.date_range_display('%m-%d')
      # if pay_period.type_display == "Weekly"
      #   json.pay_period_week_number pay_period.start_date.week_of_month
      # end
    end
  end

  def list_earning_properties(earning, user_id)
    if earning.nil?
      json.properties do
        json.total_earnings nil
      end
    else
      json.properties do
        json.total_earnings earning.amount.to_i
      end
      earning_detail_action(earning, user_id)
    end
  end

  def earning_detail_action(earning, user_id)
    actions \
      action(:detail, :get, detail_earnings_path)
      .field(:pay_period_id, :text, value: earning.pay_period_id)
      .field(:user_id, :text, value: user_id)
  end

  # Details
  def bonus_group_entities(partial_path, bonus_groups = @bonus_groups)
    json.entities bonus_groups, partial: partial_path, as: :bonus_group
  end

  def list_detail_properties(earning)
    json.properties do
      json.call(earning, :id, :amount, :user_id, :bonus_id)
      json.bonus_title earning.bonus.type_string
      json.pay_period_id earning.pay_period.id
      json.pay_period_type earning.pay_period.type_display
      
      order_entities('order', earning.orders)
    end
  end

  def bonus_group_properties(bonus_group)
    json.properties do
      json.bonus_title bonus_group.bonus.type_string
      json.subtotal bonus_group.subtotal
    end
  end

  def order_entities(partial_path, orders)
    json.entities orders, partial: partial_path, as: :order
  end

  def list_order_properties(order)
    json.properties do
      json.order_id order.id
      json.product_id order.product_id
      json.product_name order.product.name
      json.quantity order.quantity
      json.order_date order.order_date
      json.user_id order.user_id
      json.customer_id order.customer_id
    end
  end

  def list_detail_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :earning_detail
  end
end