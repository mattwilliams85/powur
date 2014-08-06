siren json

klass :quotes, :list

json.entities @quotes, partial: 'item', as: :quote

actions \
  action(:search, :get, admin_quotes_path).
    field(:search, :search, required: false).
    field(:page, :number, value: @page, min: 1, max: total_pages, required: false).
    field(:sort, :select, 
      options: Admin::QuotesController::ORDERS.keys, 
      value: @sort, required: false)

links link(:self, admin_quotes_path)