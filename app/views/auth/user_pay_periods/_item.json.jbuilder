klass :pay_period

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(pay_period, :id, :start_date, :end_date)
  json.type pay_period.type_display
end

self_link user_pay_period_path(@user.id, pay_period.id)
