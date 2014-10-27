siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

actions \
  index_action(users_path, true)
    .field(:search, :search, required: false)

links \
  link(:self, users_path)
  link(:self, profile_path)