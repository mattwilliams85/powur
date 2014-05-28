
siren = Siren.new(current_user.invites, klass: :invite)
siren.action(:create, :post, invites_path).
  field(:email, :email).
  field(:first_name, :text).
  field(:last_name, :text).
  field(:phone, :text)

json.partial! 'layouts/siren', siren: siren