siren json

klass :overrides, :list

json.entities @overrides, partial: 'item', as: :override

pay_period_ref = { url: pay_periods_path }
actions \
  action(:create, :post, overrides_path)
    .field(:type, :select, options: UserOverride::enum_options(:type))
    .field(:start_date, reference)

links link(:self, overrides_path)
