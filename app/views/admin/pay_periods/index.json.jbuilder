siren json

klass :pay_period, :list

json.entities @pay_periods, partial: 'item', as: :pay_period

links \
  link(:self, pay_periods_path)