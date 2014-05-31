siren json

klass :user

json.properties do
  json.(current_user, :email, :first_name, :last_name)
end

json.entities do
  json.partial! 'invites/entity'
end

actions \
  action(:logout, :delete, login_path)

links \
  link(:self, user_path),
  link(:edit, user_path),
  link(:index, dashboard_path)