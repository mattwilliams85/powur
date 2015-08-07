siren json

klass :goals

self_link user_goals_path(@user)

json.properties do
  json.next_rank @next_rank && @next_rank.id
end

if @next_rank
  entities(entity('user_groups',
                  'goals-user_groups',
                  groups: @next_rank.user_groups),
           entity('requirements',
                  'goals-requirements',
                  requirements: @requirements))
end

self_link user_goals_path(@user)
