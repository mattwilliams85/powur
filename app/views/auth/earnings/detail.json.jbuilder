siren json

klass :earnings_detail, :list

earnings_json.list_detail_entities('earning_detail', @earning_details)
actions index_action(@detail_earnings_path)

links link(:self, @detail_earnings_path)
