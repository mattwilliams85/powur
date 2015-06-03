siren json

klass :invite

json.properties do
  json.id @invite.id
  json.sponsor_name @invite.sponsor.full_name
  json.sponsor_avatar asset_path(@invite.sponsor.avatar.url(:thumb))
  json.first_name @invite.first_name
  json.last_name @invite.last_name
  json.email @invite.email
  json.latest_terms ApplicationAgreement.current
end

actions \
  action(:create, :post, invite_path)
  .field(:code, :hidden, value: @invite.id)
  .field(:first_name, :text, value: @invite.first_name)
  .field(:last_name, :text, value: @invite.last_name)
  .field(:email, :email, value: @invite.email)
  .field(:phone, :text, value: @invite.phone)
  .field(:zip, :text)
  .field(:password, :password),
  action(:reset, :delete, invite_path),
  action(:create_account, :patch, invite_path(format: :json))
  .field(:email, :email)
  .field(:password, :password)
  .field(:code, :code)

links \
  link(:self, promoter_path(code: @invite.id)),
  link(:new, new_promoter_path(code: @invite.id)),
  link(:index, dashboard_path)
