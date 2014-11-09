siren json

klass :data

actions action(:quotes, :get, quotes_system_path)
  .field(:start_date, :date, required: false)

links link(:self, system_path)
