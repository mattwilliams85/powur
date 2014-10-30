klass :ranks, :list

entity_rel(local_assigns[:rel])

json.properties do
  json.paths @ranks.map(&:qualification_paths).flatten.uniq
end

ranks_json.list_entities('rank', @ranks)
