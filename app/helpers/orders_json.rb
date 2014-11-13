class OrdersJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :orders, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :order

    entity_rel(rel) if rel
  end

  def list_item_properties(order = @item)
    json.properties do
      json.call(order, :quantity, :order_date, :status)
      json.product order.product.name
      json.distributor order.user.full_name
      json.customer order.customer.full_name
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :order
  end

  def admin_entities(order = @item)
    list = [
      entity('admin/products/item', 'order-product', product: order.product),
      entity(%w(list users), 'user-ancestors', upline_user_path(order.user)),
      entity('admin/users/item', 'order-user', user: order.user),
      entity('admin/customers/item', 'order-customer',
             customer: order.customer) ]

    if order.bonus_payments?
      list << entity(%w(list bonus_payments), 'order-bonus_payments',
                     admin_order_bonus_payments_path(order))
    end
    entities(*list)
  end

  def user_entities(order = @item)
    entities entity('auth/users/item', 'order-user', user: order.user)
  end
end
