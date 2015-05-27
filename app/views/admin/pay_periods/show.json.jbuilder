siren json

klass :pay_period, totals: true

json.partial! 'item', pay_period: @pay_period, detail: true

entity_list = [
  entity(%w(list orders),
         'pay_period-orders',
         pay_period_orders_path(@pay_period)) ]

if @pay_period.calculated?
  entity_list += [
    # entity(%w(list order_totals),
    #        'pay_period-order_totals',
    #        pay_period_order_totals_path(@pay_period)),
    # entity(%w(list rank_achievements),
    #        'pay_period-rank_achievements',
    #        pay_period_rank_achievements_path(@pay_period)),
    entity(%w(list bonus_payments),
           'pay_period-bonus_payments',
           pay_period_bonus_payments_path(@pay_period)) ]
end

entities(*entity_list)
