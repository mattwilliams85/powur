siren json

ranks_json.list_init

json.properties do
  json.paths @ranks.map(&:qualification_paths).flatten.uniq
end

actions ranks_json.create_action

self_link ranks_path, link(:active_qualifications, qualifications_path)
