klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(user, :id, :first_name, :last_name, :email, :phone, :level)
  json.downline_count(user.downline_count) if user.attributes['downline_count']
end

self_link user_path(user)
