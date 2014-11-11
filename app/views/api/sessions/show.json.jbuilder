siren json

klass :session

entities \
  entity('api/users/item', 'session-user', user: current_user),
  entity(%w(list users), 'user-children', api_users_path(v: params[:v])),
  entity(%w(list invites), 'user-invites', api_invites_path(v: params[:v])),
  entity(%w(list quotes), 'user-quotes', api_quotes_path(v: params[:v]))

self_link api_session_path(v: params[:v])
