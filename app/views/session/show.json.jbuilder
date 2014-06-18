siren json

klass :session, :user

json.properties do
  json.(current_user, :id, :first_name, :last_name)
end

json.entities do
  json.partial! 'auth/invites/entity'
  json.partial! 'auth/users/entity'
end

actions \
  action(:logout, :delete, login_path)

links \
  link(:self, root_path),
  link(:index, dashboard_path)