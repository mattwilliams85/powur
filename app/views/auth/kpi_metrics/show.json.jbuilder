siren json

klass :kpi_orders, :list

json.properties do
  json.order_totals #some_method
end

json.entities @periods, partial: 'item', as: :period
