siren json

klass :orders, :list

json.entities @orders, partial: 'item', as: :order

actions \
  action(:search, :get, admin_quotes_path).
    field(:search, :search, required: false).
    field(:page, :number, value: @page, min: 1, max: total_pages, required: false).
    field(:sort, :select,
      options: available_sorts.keys,
      value: @sort, required: false)

links link(:self, orders_path)
