klass :earnings_group, :earning

json.rel [ :earning ] unless local_assigns[:detail]

json.properties do
  json.section "Earnings"

  if @earnings_group[:earning].nil?
    json.call(@earnings_group[:earning], :id, :bonus_id, :amount)
  else
    json.earning @earnings_group[:earning]
  end
end