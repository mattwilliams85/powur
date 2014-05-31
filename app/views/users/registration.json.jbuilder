siren json

klass :registration

actions \
  action(:create, :post, users_path).
    field(:code, :hidden, value: @invite.id).
    field(:first_name, :text, value: @invite.first_name).
    field(:last_name, :text, value: @invite.last_name).
    field(:email, :email, value: @invite.email).
    field(:phone, :text, value: @invite.phone).
    field(:zip, :text).
    field(:password, :password)

links \
  link(:self, promoter_path(code: @invite.id)),
  link(:edit, new_promoter_path(code: @invite.id))