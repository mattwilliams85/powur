siren json

klass :data

actions action(:quotes, :get, quotes_data_path)
  .field(:start_date, :date, required: false)

links link(:self, data_path)
