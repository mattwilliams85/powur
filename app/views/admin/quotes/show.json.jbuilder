siren json

quotes_json.item_init

quotes_json.detail_properties

quotes_json.admin_entities

unless @quote.order?
  actions \
    action(:create_order, :post, admin_orders_path)
    .field(:quote_id, :number, value: @quote.id)
    .field(:order_date, :datetime, value: DateTime.current, required: false)
end

self_link admin_quote_path(@quote)
