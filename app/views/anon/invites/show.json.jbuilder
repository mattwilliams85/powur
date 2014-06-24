siren json

klass :invite

actions \
  action(:create, :post, invite_path).
    field(:code, :hidden, value: @invite.id).
    field(:first_name, :text, value: @invite.first_name).
    field(:last_name, :text, value: @invite.last_name).
    field(:email, :email, value: @invite.email).
    field('contact[phone]', :text, value: @invite.phone).
    field('contact[zip]', :text).
    field(:password, :password),
  action(:reset, :delete, invite_path)

links \
  link(:self, promoter_path(code: @invite.id)),
  link(:new, new_promoter_path(code: @invite.id))
