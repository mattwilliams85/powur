klass :pay_period

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(override, :id, :kind, :start_date, :end_date)
  json.user override.user.full_name
end

actions \
  action(:update, :patch, override_path(override))
    .field(:start_date, :select,
           required:  false,
           value:     override.start_date,
           reference: { url: pay_periods_path, id: :id, name: :title })
    .field(:end_date, :date, required: false, value: override.end_date),
  action(:delete, :delete, override_path(override))
