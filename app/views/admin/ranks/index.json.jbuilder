siren json

klass :ranks, :list

json.entities @ranks, partial: 'item', as: :rank

actions \
  action(:create, :post, ranks_path).
    field(:title, :text)

links \
  link(:self, ranks_path)