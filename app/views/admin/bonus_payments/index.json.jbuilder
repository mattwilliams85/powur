siren json

klass :bonus_payments, :list

json.entities @bonus_payments, partial: 'item', as: :bonus_payment

if paging?
  actions \
    action(:index, :get, @bonus_payments_path).
      field(:page, :number, value: paging[:current_page], min: 1, max: paging[:page_count], required: false).
      field(:sort, :select, options: paging[:sorts], value: paging[:current_sort], required: false)
end

links link(:self, @bonus_payments_path)
