siren json

klass :goals

json.properties do
  json.next_rank @next_rank.id
end

entities(entity('user_groups',
                'goals-user_groups',
                groups: @next_rank.user_groups),
         entity('requirements',
                'goals-requirements',
                requirements: @requirements))

self_link user_goals_path(@user)
