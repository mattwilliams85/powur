klass :user

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.(user, :id, :first_name, :last_name, :email, :phone, :level)
  json.downline_count(user.downline_count) if user.attributes['downline_count']
end

links \
  link(:self, admin_user_path(user)),
  link(:children, downline_admin_user_path(user)),
  link(:ancestors, upline_admin_user_path(user))