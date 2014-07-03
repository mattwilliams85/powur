klass :rank

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(rank, :id, :title)
end

json.entities [ { rank: rank, data: rank.qualifications } ], 
  partial: 'entities', as: :entity

action_list = [ ]
action_list << \
  action(:update, :patch, rank_path(rank)).
    field(:title, :text, value: rank.title)
action_list << action(:delete, :delete, rank_path(rank)) if rank.last_rank?

actions *action_list

links \
  link :self, rank_path(rank)