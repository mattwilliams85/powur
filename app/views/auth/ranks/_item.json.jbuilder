klass :rank

entity_rel :item

json.properties do
  json.call(rank, :id, :title)
end

actions(action(:delete, :delete, rank_path(rank))) if admin? && rank.last?

self_link rank_path(rank)
