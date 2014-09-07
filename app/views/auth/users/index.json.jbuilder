siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

actions \
  action(:index, :get, users_path).
    field(:search, :search, required: false)

links \
  link(:self, users_path)