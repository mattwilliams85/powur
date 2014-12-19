klass :earnings

json.properties do
  json.call(earning, :amount)
  json.pay_period_title earning.pay_period.title
  json.pay_period_type earning.pay_period.type_display
  json.pay_period_date_range earning.pay_period.date_range_display('%m-%d')
  json.pay_period_week_number earning.pay_period.start_date.week_of_month
end
