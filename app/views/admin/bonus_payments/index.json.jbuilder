siren json

klass :bonus_payments, :list

json.entities @bonus_payments, partial: 'item', as: :bonus_payment

index_action = action(:index, :get, @bonus_payments_path)
if paging?
  index_action.
    field(:page, :number, value: paging[:current_page], min: 1, max: paging[:page_count], required: false).
    field(:sort, :select, options: paging[:sorts], value: paging[:current_sort], required: false)
end
if filtering?
  filters.each do |scope, opts|
    index_action.field(scope, :select,
      reference: { 
        url:  instance_exec(&opts[:url]), 
        id:   opts[:id], 
        name: opts[:name] }, required: false)
  end
end

actions index_action

links link(:self, @bonus_payments_path)
