siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

self_link request.path
