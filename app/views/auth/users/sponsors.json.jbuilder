siren json

klass :users, :list

json.entities @users, partial: 'sponsor_item', as: :sponsor

links \
  link(:self, users_path)