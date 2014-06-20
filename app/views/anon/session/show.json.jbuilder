siren json

klass :session, :user

json.properties do
  json.(current_user, :id, :first_name, :last_name)
end

json.entities do
  json.partial! 'auth/invites/entity'
  json.partial! 'auth/users/entity'
  json.partial! 'auth/quotes/entity'
end

actions \
  action(:logout, :delete, login_path)

link_list = [ link(:self, root_path), link(:index, dashboard_path) ]
link_list << link(:users, admin_users_path) if current_user.has_role?(:admin)
links *link_list
