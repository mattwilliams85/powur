siren json

resources_json.list_init

json.properties do
  json.topics @resources.map(&:topic).compact.uniq
end

self_link resources_path
