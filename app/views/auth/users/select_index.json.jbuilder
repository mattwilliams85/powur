siren json

klass :users, :list

json.entities @users, partial: 'auth/users/select_item', as: :user

self_link request.path
