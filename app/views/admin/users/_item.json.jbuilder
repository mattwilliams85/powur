klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(user, :id, :first_name, :last_name, :email, :phone)
  json.downline_count(user.downline_count) if user.attributes['downline_count']
end

links \
  link :self, admin_user_path(user)