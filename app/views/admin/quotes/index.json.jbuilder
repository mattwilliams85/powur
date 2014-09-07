siren json

klass :quotes, :list

json.entities @quotes, partial: 'item', as: :quote

actions \
  action(:index, :get, admin_quotes_path).
    field(:search, :search, required: false).
    field(:page, :number, value: paging[:current_page], min: 1, max: paging[:page_count], required: false).
    field(:sort, :select,
      options: paging[:sorts],
      value: paging[:current_sort], required: false)

links link(:self, admin_quotes_path)
