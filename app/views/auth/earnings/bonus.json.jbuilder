siren json
# earnings_json.list_entities('earning_period', @earnings_group)

klass :bonus_summary, :list
# json.entities @earnings, partial: 'item', as: :earning

earnings_json.list_bonus_summary('pay_period_detail', @bonus_summary)

# earnings_json.list_bonus_summary(@bonus_summary)

json.properties do 
  json.total @total.to_i
  json.pay_period_id params[:pay_period_id]  
end

# links link(:self, @earnings_path)

