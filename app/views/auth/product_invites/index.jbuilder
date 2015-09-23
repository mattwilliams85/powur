siren json

klass :product_invites, :list

json.entities @invites, partial: 'item', as: :invite

self_link request.path
