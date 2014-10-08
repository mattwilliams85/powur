siren json

klass :pay_period, totals: true

json.partial! 'item', pay_period: @pay_period, detail: true

if @pay_period.calculated?
  entities \
    ref_entity(%w(list orders),
               'pay_period-orders',
               pay_period_orders_path(@pay_period)),
    ref_entity(%w(list order_totals),
               'pay_period-order_totals',
               pay_period_order_totals_path(@pay_period)),
    ref_entity(%w(list rank_achievements),
               'pay_period-rank_achievements',
               pay_period_rank_achievements_path(@pay_period)),
    ref_entity(%w(list bonus_payments),
               'pay_period-bonus_payments',
               pay_period_bonus_payments_path(@pay_period))
end
