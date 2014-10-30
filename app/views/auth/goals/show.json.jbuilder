siren json

klass :goals

json.properties do
  json.pay_as_rank @pay_as_rank
end

entities(entity('order_totals', 'goals-order_totals'),
         entity('ranks', 'goals-ranks'))

self_link user_goals_path(@user)
