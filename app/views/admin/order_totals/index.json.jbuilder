siren json

klass :order_totals, :list

json.entities @order_totals, partial: 'item', as: :order_total

actions \
  action(:list, :get, @orders_totals_path).
    field(:page, :number, value: @page, min: 1, max: total_pages, required: false).
    field(:sort, :select, options: available_sorts.keys, value: @sort, required: false)

links link(:self, @orders_totals_path)
