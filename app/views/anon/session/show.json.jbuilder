siren json

klass :session, :user

json.properties do
  json.call(current_user, :id, :first_name, :last_name, :full_name,
            :email, :phone, :address, :city, :state, :zip,
            :bio, :twitter_url, :facebook_url, :linkedin_url,
            :lifetime_rank, :organic_rank, :level, :partner?)

  json.avatar do
    [ :thumb, :preview, :large ].each do |key|
      json.set! key, asset_path(current_user.avatar.url(key))
    end
  end if current_user.avatar?
  json.is_admin current_user.role?(:admin)

  unless current_user.accepted_latest_terms?
    json.latest_terms ApplicationAgreement.current
  end

  # Hstore stores booleans as strings; below converts back to boolean
  json.watched_intro current_user.watched_intro == 'true'

  json.notification current_user.latest_unread_notification.try(:content)

  json.metrics do
    json.call(current_user.metrics,
              :team_count, :earnings, :co2_saved, :login_streak)
  end

  json.preview_video_embed_url(
    SystemSettings.get!('preview_video_embed_url'))
end

actions_list = [
  action(:logout, :delete, login_path),
  action(:update_profile, :patch, profile_path)
]
entity_list = []
link_list = [
  link(:self, root_path)
]

entity_list << entity(%w(goals), 'user-goals', user_goals_path(current_user))
entity_list << entity(%w(goals), 'user-kpis', kpi_metrics_path)
entity_list << entity(%w(list invites),
                      'user-invites',
                      invites_path(page: '{page}', status: '{status}'))
entity_list << entity(%w(list solar_invites),
                      'user-solar_invites',
                      product_invites_path(page: '{page}', status: '{status}'))
entity_list << entity(%w(list users), 'user-users', users_path)
entity_list << entity(%w(list leads),
                      'user-leads',
                      user_leads_path(current_user, days: '{days}'))
entity_list << entity(%w(list leads),
                      'user-team_leads',
                      team_leads_path(days: '{days}'))
entity_list << entity(%w(list leads),
                      'user-grid_leads',
                      grid_leads_path(days: '{days}'))
entity_list << entity(%w(search leads),
                      'user-team_leads_search',
                      team_leads_path(search: '{search}'))
entity_list << entity(%w(user), 'user-profile', profile_path)
entity_list << entity(%w(summary leads),
                      'user-leads_summary',
                      summary_user_leads_path(current_user, days: '{days}'))
entity_list << entity(%w(grid_summary user),
                      'user-grid_summary',
                      grid_summary_user_path(current_user, days: '{days}'))

link_list << link(:index, dashboard_path)

# if current_user.accepted_latest_terms?
#   entity_list << entity(%w(goals), 'user-goals', user_goals_path(current_user))
#   entity_list << entity(%w(list invites), 'user-invites', invites_path)
#   entity_list << entity(%w(list users), 'user-users', users_path)
#   entity_list << entity(%w(list leads), 'user-leads', leads_path(current_user))
#   entity_list << entity(%w(user), 'user-profile', profile_path)
#   link_list << link(:index, dashboard_path)
# end

if current_user.role?(:admin)
  entity_list << entity(%w(list users), 'admin-users', admin_users_path)
  entity_list << entity(%w(list user_groups),
                        'admin-user_groups',
                        user_groups_path)
  entity_list << entity(%w(list ranks), 'ranks', ranks_path)
  entity_list << entity(%w(list products), 'admin-products', products_path)
  entity_list << entity(%w(list pay_periods),
                        'admin-pay_periods',
                        pay_periods_path)

  link_list << link(:admin, admin_root_path)
end

actions(*actions_list)
entities(*entity_list)
links(*link_list)
