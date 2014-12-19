siren json
klass :earnings
json.entities @earnings, partial: 'item', as: :earning

actions index_action(@earnings_path, false)

links link(:self, @earnings_path)
