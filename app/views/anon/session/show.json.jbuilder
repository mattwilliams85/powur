siren json

klass :session, :user

json.properties do
  json.call(current_user, :id, :first_name, :last_name)
end

entity_list = [
  entity(%w(list invites), 'user-invites', invites_path),
  entity(%w(list users), 'user-users', users_path),
  entity(%w(list quotes), 'user-quotes', user_quotes_path),
  entity(%w(user), 'user-profile', profile_path),
  entity(%w(goals), 'user-goals', user_goals_path(current_user)) ]
if current_user.role?(:admin)
  entity_list << entity(%w(list users), 'admin-users', admin_users_path)
  entity_list << entity(%w(system), 'admin-system', system_path)
end

entities(*entity_list)

actions action(:logout, :delete, login_path)

link_list = [ link(:self, root_path), link(:index, dashboard_path) ]
if current_user.role?(:admin)
  link_list << link(:admin, admin_root_path)
end

links(*link_list)
