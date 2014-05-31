siren json

klass :session

actions \
  action(:accept_invite, :post, invite_accept_path).
    field(:code, :text),
  action(:create, :post, login_path).
    field(:email, :email).
    field(:password, :password)

links \
  link(:self, root_path)