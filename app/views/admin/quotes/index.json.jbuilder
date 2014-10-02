siren json

klass :quotes, :list

json.entities @quotes, partial: 'item', as: :quote

actions index_action(admin_quotes_path, true)

links link(:self, admin_quotes_path)
