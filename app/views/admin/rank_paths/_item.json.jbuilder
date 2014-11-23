klass :rank_path

json.properties do
  json.call(rank_path, :id, :name, :description)
end

actions \
  action(:update, :patch, rank_path_path(rank_path))
  .field(:name, :text, value: rank_path.name, required: true)
  .field(:description, :text, value: rank_path.description, required: false),
  action(:delete, :delete, rank_path_path(rank_path))
