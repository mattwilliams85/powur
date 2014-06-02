siren json

klass :session, :user

json.properties do
  json.(current_user, :email, :first_name, :last_name)
end

json.entities do
  json.partial! 'invites/entity'
  json.partial! 'users/entity'
end

actions \
  action(:logout, :delete, login_path)

links \
  link(:self, root_path),
  link(:index, dashboard_path)