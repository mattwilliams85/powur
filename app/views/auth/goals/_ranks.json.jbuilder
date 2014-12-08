klass :ranks, :list

entity_rel(local_assigns[:rel])

# TODO: determine if this is needed and remove if not
json.properties do
  json.paths @ranks.map { |r| r.grouped_qualifiers.keys }.flatten.compact.uniq
end

ranks_json.list_entities('rank', @ranks)
