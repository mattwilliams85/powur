siren json

klass :rank_paths, :list

json.entities @rank_paths, partial: 'item', as: :rank_path

self_link rank_paths_path
