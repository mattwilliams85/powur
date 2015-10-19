siren json

klass :session, :anonymous

actions_list = [
  action(:update_password, :put, password_path)
    .field(:password, :password)
    .field(:password_confirm, :password)
    .field(:token, :text) ]

actions(*actions_list)
