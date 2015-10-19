siren json

klass :session, :anonymous

actions_list = [
  action(:create, :post, login_path)
    .field(:email, :email)
    .field(:password, :password)
    .field(:remember_me, :boolean),
  action(:reset_password, :post, password_path)
    .field(:email, :email) ]

actions(*actions_list)

entity_list = [ entity(%w(solar_invite),
                       'customer-solar_invite',
                       customer_path('{code}')),
                entity(%w(grid_invite),
                       'user-solar_invite',
                       invite_path('{code}')),
                entity(%w(password_token),
                       'user-password_token',
                       reset_token_password_path('{code}')) ]

entities(*entity_list)

self_link root_path
