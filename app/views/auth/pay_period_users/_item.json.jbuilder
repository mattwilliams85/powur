klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(user, :id, :full_name)
  json.pay_as_rank user.pay_as_rank(@pay_period.id)
  json.force_rank user.override_rank(@pay_period.id)
  json.bonus_total @bonus_total || user.attributes['bonus_total'] || 0.0
end
