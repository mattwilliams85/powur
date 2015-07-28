klass :purchases, :list

entity_rel(rel)

json.entities @purchases, partial: 'auth/purchases/item', as: :purchase
