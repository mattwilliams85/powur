siren json

klass :invite

json.properties do
  json.call(@invite, :id, :first_name, :last_name, :email, :status)

  json.sponsor_first_name @invite.sponsor.first_name
  json.sponsor_last_name @invite.sponsor.last_name
  json.sponsor_email @invite.sponsor.email
  json.sponsor_avatar asset_path(@invite.sponsor.avatar.url(:thumb))
  json.latest_terms ApplicationAgreement.current
end

if @invite.status == 'valid'
  actions \
    action(:accept_invite, :patch, invite_path)
    .field(:code, :hidden, value: @invite.id)
    .field(:first_name, :text, value: @invite.first_name)
    .field(:last_name, :text, value: @invite.last_name)
    .field(:email, :email, value: @invite.email)
    .field(:phone, :text, value: @invite.phone)
    .field(:address, :text)
    .field(:city, :text)
    .field(:state, :text)
    .field(:zip, :text)
    .field(:password, :password)
    .field(:password_confirmation, :password)
    .field(:tos, :checkbox, value: true)
    .field(:tos_version, :hidden, value: ApplicationAgreement.current.version)
end
