
siren = Siren.new(:session)

siren.action(:create, :post, login_path).
  field(:email, :email).
  field(:password, :password)

json.partial! 'layouts/siren', siren: siren