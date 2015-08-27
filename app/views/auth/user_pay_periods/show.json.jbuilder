siren json

klass :pay_period

json.partial! 'item', pay_period: @pay_period

entities(entity('bonus_totals',
                'user-bonus_totals',
                bonus_totals: @bonus_totals),
         entity('auth/pay_period_users/bonus_payments',
                'user-bonus_payments',
                bonus_payments: @bonus_payments))

self_link request.path
