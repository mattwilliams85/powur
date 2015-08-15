siren json

klass :goals

self_link user_goals_path(@user)

json.properties do
  json.next_rank @next_rank && @next_rank.id
  lifetime_rank = all_ranks[@user.lifetime_rank || 0]
  json.rank_list = all_ranks
  json.lifetime_rank_title lifetime_rank && lifetime_rank.title
end

if @next_rank
  entities(entity('requirements',
                  'goals-requirements',
                  requirements: @requirements))
end

self_link user_goals_path(@user)
