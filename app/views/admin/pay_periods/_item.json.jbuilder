klass :pay_period

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(pay_period, :id, :start_date, :end_date, :title)
  json.type pay_period.type_display
  json.calculated pay_period.calculated?
end

unless local_assigns[:read_only]
  action_list = []

  if pay_period.calculated?
    action_list << action(:recalculate, :post,
                          recalculate_pay_period_path(pay_period))
  elsif can_calculate?(pay_period)
    action_list << action(:calculate, :post,
                          calculate_pay_period_path(pay_period))
  end

  actions(*action_list)
end

links link(:self, pay_period_path(pay_period))
