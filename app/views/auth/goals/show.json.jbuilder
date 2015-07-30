siren json

klass :goals

self_link user_goals_path(@user)

json.properties do
  json.next_rank @next_rank && @next_rank.id
end

if @next_rank
    entities(entity('user_groups',
                    'goals-user_groups',
                    groups: @next_rank.user_groups),
             entity('requirements',
                    'goals-requirements',
                    requirements: @requirements),
             entity('purchases',
                    'goals-purchases',
                    purchases: @purchases),
             entity('order_totals',
                    'goals-order_totals',
                    order_totals: @order_totals))
end

self_link user_goals_path(@user)
