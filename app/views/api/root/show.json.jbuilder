siren json

klass :api

actions \
  action(:password, :post, api_password_path)
  .field(:email, :email, required: true),
  action(:token, :post, api_token_path(v: params[:v]))
  .field(:grant_type, :text, value: 'password', required: true)
  .field(:username, :email, required: true)
  .field(:password, :password, required: true),
  action(:refresh_token, :post, api_token_path(v: params[:v]))
  .field(:grant_type, :text, value: 'refresh_token', required: true)
  .field(:refresh_token, :text, required: true)

self_link api_root_path
