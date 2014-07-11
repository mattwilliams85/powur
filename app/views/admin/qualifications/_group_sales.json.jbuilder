
json.properties do
  json.(qualification, :period, :quantity, :max_leg_percent)
end

action_list << action(:update, :patch, 
  rank_qualification_path(qualification.rank, qualification)).
    field(:path, :text, value: qualification.path).
    field(:period, :select, 
      options: { pay_period: 'Pay Period', lifetime: 'Lifetime' }, 
      value: qualification.period).
    field(:quantity, :number, value: qualification.quantity).
    field(:max_leg_percent, :number, value: qualification.max_leg_percent)

actions *action_list