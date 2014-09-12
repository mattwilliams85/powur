
klass :rank_achievement

json.properties do
  json.(rank_achievement, :pay_period_id, :user_id, :path, :rank_id, :achieved_at)
  json.lifetime rank_achievement.lifetime?
  json.user rank_achievement.user.full_name
  json.rank rank_achievement.rank.title
end