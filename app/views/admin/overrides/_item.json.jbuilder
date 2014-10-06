klass :pay_period

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(override, :id, :type, :start_date, :end_date)
  json.user override.user.full_name
end