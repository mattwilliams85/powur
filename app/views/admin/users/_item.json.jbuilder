klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(user, :id, :first_name, :last_name, :email, :phone)
  json.downlink_count 12
end

links \
  link :self, admin_user_path(user)