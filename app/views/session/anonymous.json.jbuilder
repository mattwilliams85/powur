siren json

klass :session, :anonymous

actions \
  action(:create, :post, login_path).
    field(:email, :email).
    field(:password, :password),
  action(:reset_password, :post, login_password_path).
    field(:email, :email)
  action(:accept_invite, :post, invite_login_path).
    field(:code, :text)

links \
  link(:self, root_path)