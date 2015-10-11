siren json

klass :session, :anonymous

actions_list = [
  action(:create, :post, login_path)
    .field(:email, :email)
    .field(:password, :password),
  action(:reset_password, :post, password_path)
    .field(:email, :email),
  action(:validate_zip, :post, validate_zip_validator_path)
    .field(:zip, :text) ]

actions(*actions_list)
links(link(:self, root_path))
