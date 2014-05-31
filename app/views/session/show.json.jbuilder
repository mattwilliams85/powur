
siren json

klass :session

actions \
  action(:create, :post, login_path).
    field(:email, :email).
    field(:password, :password)

links \
  link :self, login_path