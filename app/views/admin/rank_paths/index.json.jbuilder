siren json

klass :rank_paths, :list

json.entities @rank_paths, partial: 'item', as: :rank_path

actions action(:create, :post, rank_paths_path)
  .field(:name, :text, required: true)
  .field(:description, :text, required: false)

self_link rank_paths_path
