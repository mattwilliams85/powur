klass :rank_path

json.properties do
  json.call(rank_path, :id, :name)
end

actions \
  action(:update, :patch, rank_path_path(rank_path))
    .field(:name, :text, value: rank_path.name, required: true),
  action(:delete, :delete, rank_path_path(rank_path))
