siren json

klass :session, :user

json.properties do
  json.call(current_user, :id, :first_name, :last_name)
  unless current_user.accepted_latest_terms?
    json.latest_terms ApplicationAgreement.current
  end
end

actions_list = [
  action(:logout, :delete, login_path)
]
entity_list = []
link_list = [
  link(:self, root_path)
]

if current_user.accepted_latest_terms?
  entity_list << entity(%w(list invites), 'user-invites', invites_path)
  entity_list << entity(%w(list users), 'user-users', users_path)
  entity_list << entity(%w(list quotes), 'user-quotes', user_quotes_path(current_user))
  entity_list << entity(%w(user), 'user-profile', profile_path)
  entity_list << entity(%w(goals), 'user-goals', user_goals_path(current_user))

  link_list << link(:index, dashboard_path)
  link_list << link(:profile, profile_path)
end

if current_user.role?(:admin)
  entity_list << entity(%w(list users), 'admin-users', admin_users_path)
  entity_list << entity(%w(list user_groups), 'admin-user_groups', user_groups_path)
  entity_list << entity(%w(list ranks), 'ranks', ranks_path)
  entity_list << entity(%w(list products), 'admin-products', products_path)

  link_list << link(:admin, admin_root_path)
end

actions(*actions_list)
entities(*entity_list)
links(*link_list)
