siren json

klass :earning_details, :list

earnings_json.list_detail_entities('earning_detail', @bonus_payments)
actions index_action(@detail_earnings_path)

links link(:self, @detail_earnings_path)