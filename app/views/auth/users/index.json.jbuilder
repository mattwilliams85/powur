siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

actions index_action(request.path, true)

self_link request.path
