siren json

klass :pay_periods, :list

json.entities @pay_periods, partial: 'item', as: :pay_period

links link(:self, pay_periods_path)
