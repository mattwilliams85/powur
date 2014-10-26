siren json

klass :session, :user

json.properties do
  json.call(current_user, :id, :first_name, :last_name)
end

entity_list = [
  entity(%w(list invites), 'user-invites', invites_path),
  entity(%w(list users), 'user-users', users_path),
  entity(%w(list quotes), 'user-quotes', user_quotes_path),
  entity(%w(user), 'user-profile', profile_path) ]
if current_user.has_role?(:admin)
  entity_list << entity(%w(list users), 'admin-users', admin_users_path)
  entity_list << entity(%w(data), 'admin-data', data_path)
end

entities(*entity_list)

actions action(:logout, :delete, login_path)

link_list = [ link(:self, root_path), link(:index, dashboard_path) ]
if current_user.has_role?(:admin)
  link_list << link(:users, admin_users_path)
  link_list << link(:profile, profile_path)
  link_list << link(:ranks, ranks_path)
  link_list << link(:products, products_path)
  link_list << link(:bonus_plans, bonus_plans_path)
  link_list << link(:quotes, admin_quotes_path)
  link_list << link(:orders, admin_orders_path)
  link_list << link(:pay_periods, pay_periods_path)
end

links(*link_list)
