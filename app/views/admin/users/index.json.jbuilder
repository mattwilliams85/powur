siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

actions \
  action(:search, :get, admin_users_path).
    field(:q, :text)

links \
  link(:self, admin_users_path)