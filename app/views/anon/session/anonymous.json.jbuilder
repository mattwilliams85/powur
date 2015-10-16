siren json

klass :session, :anonymous

actions_list = [
  action(:create, :post, login_path)
    .field(:email, :email)
    .field(:password, :password)
    .field(:remember_me, :boolean),
  action(:reset_password, :post, password_path)
    .field(:email, :email),
  action(:validate_zip, :post, zip_validator_path)
      .field(:zip, :text)
      .field(:code, :text),
  action(:accept_invite, :patch, invite_path('{code}'))
  .field(:code, :hidden)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:email, :email)
  .field(:phone, :text)
  .field(:address, :text)
  .field(:city, :text)
  .field(:state, :text)
  .field(:zip, :text)
  .field(:password, :password)
  .field(:tos, :checkbox, value: true)
  .field(:tos_version, :hidden, value: ApplicationAgreement.current.version)
]


actions(*actions_list)

entity_list = [ entity(%w(solar_invite),
                       'customer-solar_invite',
                        product_invite_path('{code}')),
                entity(%w(grid_invite),
                      'user-solar_invite',
                       invite_path('{code}'))]
entities(*entity_list)

self_link root_path