siren json

klass :ranks, :list

# TODO: determine if this is needed and remove if not
json.properties do
  json.paths @ranks.map { |r| r.grouped_qualifiers.keys }.flatten.compact.uniq
end

ranks_json.list_entities

actions ranks_json.create_action

self_link ranks_path
