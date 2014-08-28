
klass :rank_achievement

json.properties do
  json.(rank_achievement, :path, :rank_id)
  json.user rank_achievement.user.full_name
  json.rank rank_achievement.rank.display
end