siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

actions \
  action(:search, :get, users_path).
    field(:q, :text)

links \
  link(:self, users_path)