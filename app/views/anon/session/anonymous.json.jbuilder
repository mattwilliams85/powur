siren json

klass :session, :anonymous

actions_list = [
  action(:create, :post, login_path)
    .field(:email, :email)
    .field(:password, :password),
  action(:reset_password, :post, password_path)
    .field(:email, :email),
  action(:solar_invite, :get, '/product_invites/'),
  action(:validate_zip, :post, zip_validator_path)
    .field(:zip, :text)
    .field(:code, :text),
  action(:validate_grid_invite, :post, validate_invite_path)
    .field(:code, :text) ]

actions(*actions_list)
links(link(:self, root_path))
