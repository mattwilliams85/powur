klass :pay_period

json.rel [ :item ] unless local_assigns[:detail]

def format_date_range(pp)
  pp.start_date.strftime("(%b #{pp.start_date.day.ordinalize} %Y") +
    ' - ' +
    pp.end_date.strftime(" %b #{pp.end_date.day.ordinalize} %Y)")
end

json.properties do
  json.call(pay_period, :id, :start_date, :end_date)
  json.type pay_period.type_display
  json.date_range format_date_range(pay_period)
end

self_link user_pay_period_path(@user.id, pay_period.id)
