siren json

klass :order_totals, :list

json.entities @order_totals, partial: 'item', as: :order_total

if paging?
  actions \
    action(:list, :get, @orders_totals_path).
      field(:page, :number, value: paging[:current_page], min: 1, max: paging[:page_count], required: false).
      field(:sort, :select, options: paging[:sorts], value: paging[:current_sort], required: false)
end

links link(:self, @orders_totals_path)