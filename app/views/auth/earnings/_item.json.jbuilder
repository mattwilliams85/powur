klass :earnings_group, :pay_period

json.rel [ :item ] unless local_assigns[:detail]


earnings_json.list_item_properties(@earnings_group[:pay_period])
#earnings_json.list_item_properties(@earnings_group[:earning])
