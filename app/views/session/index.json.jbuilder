klass :session
action(:session, :post, login_path).field(:email, :email).field(:password, :password)
json.partial! 'layouts/siren'