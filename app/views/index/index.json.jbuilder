siren json

klass :session

code = params[:code] ? { value: params[:code] } : {}

actions \
  action(:accept_invite, :post, invite_accept_path).
    field(:code, :text, code),
  action(:create, :post, login_path).
    field(:email, :email).
    field(:password, :password)

links \
  link(:self, root_path)