siren json

klass :quotes, :list

json.entities @quotes, partial: 'item', as: :quote

links link(:self, admin_quotes_path)