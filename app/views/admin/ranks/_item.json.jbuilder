klass :rank

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(rank, :id, :title)
end

links \
  link :self, rank_path(rank)