siren json

klass :orders, :list

json.entities @orders, partial: 'item', as: :order

actions \
  action(:index, :get, @orders_path || orders_path).
    field(:search, :search, required: false).
    field(:page, :number, value: paging[:current_page],
      min: 1, max: paging[:page_count], required: false).
    field(:sort, :select,
      options: paging[:sorts],
      value: paging[:current_sort], required: false)

links link(:self, @orders_path || orders_path)
