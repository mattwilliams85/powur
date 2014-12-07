klass :rank_path

json.properties do
  json.call(rank_path, :id, :name, :description, :precedence)
end

action_list = [
  action(:update, :patch, rank_path_path(rank_path))
  .field(:name, :text, value: rank_path.name, required: true)
  .field(:description, :text, value: rank_path.description, required: false) ]
if !rank_path.default? || all_paths.size == 1
  action_list << action(:delete, :delete, rank_path_path(rank_path))
end

actions(*action_list)
