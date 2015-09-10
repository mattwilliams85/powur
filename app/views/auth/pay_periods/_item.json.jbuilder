klass :pay_period

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(pay_period, :id, :status, :start_date, :end_date)
  json.total_bonus pay_period.bonus_payments.sum(:amount)
  json.type pay_period.type_display
end

self_link pay_period_path(pay_period)
