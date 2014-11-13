siren json

pp_json.item_init

entities \
  entity('bonus_payments',
         'pay-period_bonus_payments',
         bonus_payments: @bonus_payments)

self_link admin_user_pay_period_path(@user, @pay_period)
