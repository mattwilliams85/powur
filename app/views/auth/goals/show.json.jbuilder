siren json

klass :goals

self_link user_goals_path(@user)

return unless @next_rank

json.properties do
  json.next_rank @next_rank.id
end

entities(entity('user_groups',
                'goals-user_groups',
                groups: @next_rank.user_groups),
         entity('requirements',
                'goals-requirements',
                requirements: @requirements),
         entity('enrollments',
                'goals-enrollments',
                requirements: @entrollments))

self_link user_goals_path(@user)
