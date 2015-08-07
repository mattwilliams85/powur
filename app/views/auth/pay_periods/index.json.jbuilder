siren json

klass :pay_periods, :list

json.entities @pay_periods, partial: 'item', as: :pay_period

self_link request.path
