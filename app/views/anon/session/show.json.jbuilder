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
  entity_list << entity(%w(list user_groups), 'admin-user_groups', user_groups_path)
  entity_list << entity(%w(system), 'admin-system', system_path)
  entity_list << entity(%w(list ranks), 'ranks', ranks_path)
  entity_list << entity(%w(list products), 'admin-products', products_path)
  # entity_list << entity(%w(list rank_paths),
  #                       'admin-rank_paths',
  #                       rank_paths_path)
  # entity_list << entity(%w(list active_qualifications),
  #                       'admin-active_qualifications',
  #                       qualifications_path)
end

entities(*entity_list)

actions action(:logout, :delete, login_path)

link_list = [
  link(:self, root_path),
  link(:index, dashboard_path),
  link(:profile, profile_path) ]
link_list << link(:admin, admin_root_path) if current_user.role?(:admin)

links(*link_list)
