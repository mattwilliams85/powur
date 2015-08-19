siren json

klass :user

json.partial! 'item', lead_totals: @lead_totals

entities(entity('bonus_payments',
                'user-bonus_payments',
                bonus_payments: @bonus_payments))

self_link request.path
