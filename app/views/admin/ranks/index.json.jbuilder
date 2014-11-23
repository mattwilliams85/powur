siren json

klass :ranks, :list

json.properties do
  json.paths @ranks.map(&:qualification_paths).flatten.uniq
end

ranks_json.list_entities

actions ranks_json.create_action

self_link ranks_path
