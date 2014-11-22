siren json

ranks_json.list_init

json.properties do
  json.paths @ranks.map(&:qualification_paths).flatten.uniq
end

entities entity('list active_qualifications',
                'ranks-active_qualifications',
                qualifications_path)

actions ranks_json.create_action

self_link ranks_path
