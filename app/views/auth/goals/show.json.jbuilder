siren json

klass :goals

json.properties do
  json.pay_as_rank @pay_as_rank
  json.next_rank @next_rank.id
end

ent_list = []
if @next_rank
  ent_list << entity('auth/qualifications/index', 'goals-qualifications')
end

entities(*ent_list)

self_link user_goals_path(@user)
