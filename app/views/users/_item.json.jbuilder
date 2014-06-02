klass :class, :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(user, :id, :first_name, :last_name)
end

links \
  link :self, user_path(user)


