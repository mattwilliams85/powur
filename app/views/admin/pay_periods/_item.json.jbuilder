klass :pay_period

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(pay_period, :id, :start_date, :end_date)
  json.type pay_period.type_display
  json.calculated pay_period.calculated?
end

action_list = [ ]

unless pay_period.calculated?
  action_list << \
    action(:calculate, :post, calculate_pay_period_path(pay_period))
end

actions *action_list

links \
  link :self, pay_period_path(pay_period)