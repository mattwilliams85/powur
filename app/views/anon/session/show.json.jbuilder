siren json

klass :session, :user

json.properties do
  json.(current_user, :id, :first_name, :last_name)
end

list = %w(auth/invites auth/users auth/quotes)
list << 'admin/users' if current_user.has_role?(:admin)
entities *list

actions \
  action(:logout, :delete, login_path)

link_list = [ link(:self, root_path), link(:index, dashboard_path) ]
link_list << link(:users, admin_users_path) if current_user.has_role?(:admin)
links *link_list
