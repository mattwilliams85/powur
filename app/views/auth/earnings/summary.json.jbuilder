siren json
earnings_json.list_entities('earning_period', @earnings_group)

klass :earnings, :list
# json.entities @earnings, partial: 'item', as: :earning

actions index_action(@earnings_path, false)

json.properties do
  json.current_week Date.today().week_of_month
  json.accumulated_total @total_earnings
  json.start_month params[:start_month]
  json.end_month params[:end_month]
  json.start_year params[:start_year]
  json.end_year params[:end_year]
end

# links link(:self, @earnings_path)

