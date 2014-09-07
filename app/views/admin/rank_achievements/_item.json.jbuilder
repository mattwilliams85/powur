
klass :rank_achievement

json.properties do
  json.(rank_achievement, :path, :rank_id, :achieved_at)
  json.lifetime rank_achievement.lifetime?
  json.user rank_achievement.user.full_name
  json.rank rank_achievement.rank.display
end