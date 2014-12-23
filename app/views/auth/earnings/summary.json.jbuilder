siren json
klass :earnings, :list
json.entities @earnings, partial: 'item', as: :earning
actions index_action(@earnings_path, false)
json.properties do
  json.current_week Date.today().week_of_month
  json.accumulated_total @total_earnings
end

links link(:self, @earnings_path)
