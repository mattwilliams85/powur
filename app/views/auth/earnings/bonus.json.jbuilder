siren json

klass :bonus_summary, :list
earnings_json.list_bonus_summary('pay_period_detail', @bonus_summary)
json.properties do
  json.total @total.to_i
  json.pay_period_id params[:pay_period_id]
end
