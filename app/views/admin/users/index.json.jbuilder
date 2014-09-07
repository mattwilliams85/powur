siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

actions \
  action(:index, :get, admin_users_path).
    field(:search, :search, required: false)

links \
  link(:self, admin_users_path)