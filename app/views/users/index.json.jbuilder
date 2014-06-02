siren json

klass :users, :list

json.entities @users, partial: 'item', as: :user

links \
  link(:self, users_path)