klass :rank

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(rank, :id, :title)
end

action_list = [action(:update, :patch, rank_path(rank)).
    field(:title, :text, value: rank.title)]
action_list << action(:delete, :delete, rank_path(rank)) if rank.last_rank?

actions *action_list

begin
  
rescue Exception => e
  binding.pry
  raise e  
end

links \
  link :self, rank_path(rank)