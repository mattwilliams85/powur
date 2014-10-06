klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(user, :id, :first_name, :last_name, :email, :phone, :level)
  json.downline_count(user.downline_count) if user.attributes['downline_count']
end

links \
  link(:self, user_path(user)),
  link(:children, downline_user_path(user)),
  link(:ancestors, upline_user_path(user)),
  link(:orders, user_orders_path(user)),
  link(:order_totals, user_order_totals_path(user)),
  link(:rank_achievements, user_rank_achievements_path(user)),
  link(:profile, profile_path)