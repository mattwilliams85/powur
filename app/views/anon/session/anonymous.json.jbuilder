siren json

klass :session, :anonymous

actions_list = [
  action(:create, :post, login_path)
    .field(:email, :email)
    .field(:password, :password)
    .field(:remember_me, :boolean),
  action(:reset_password, :post, password_path)
    .field(:email, :email),
  action(:solar_invite, :get, '/product_invites/'),
  action(:validate_zip, :post, zip_validator_path)
    .field(:zip, :text)
    .field(:code, :text),
  action(:validate_grid_invite, :post, invite_path)
    .field(:code, :text) ]

actions(*actions_list)

entity_list = [ entity(%w(solar_invite),
                       'customer-solar_invite',
                       product_invite_path('{code}')),
                entity(%w(grid_invite),
                'user-solar_invite',
                invite_path('{code}')),]
entities(*entity_list)

self_link root_path