
json.properties do
  json.(qualification, :name)
end

action_list << action(:update, :patch, 
  rank_qualification_path(qualification.rank, qualification)).
    field(:path, :text, value: qualification.path).
    field(:name, :text, value: qualification.name)

actions *action_list

