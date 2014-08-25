siren json

json.partial! 'item', pay_period: @pay_period, detail: true

if @pay_period.calculated?
  ents \
    ent(%w(list order_totals), 'pay_period-order_totals', pay_period_order_totals_path(@pay_period))
end
