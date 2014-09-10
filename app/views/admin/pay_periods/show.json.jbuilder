siren json

json.partial! 'item', pay_period: @pay_period, detail: true

if @pay_period.calculated?
  ents \
    ent(%w(list order_totals), 'pay_period-order_totals', pay_period_order_totals_path(@pay_period)),
    ent(%w(list rank_achievements), 'pay_period-rank_achievements', pay_period_rank_achievements_path(@pay_period)),
    ent(%w(list bonus_payments), 'pay_period-bonus_payments', pay_period_bonus_payments_path(@pay_period))
end
