siren json

klass :invites, :list

json.properties do
  json.remaining current_user.remaining_invites
end

json.entities @invites, partial: 'item', as: :invite

actions \
  action(:create, :post, invites_path).
    field(:email, :email).
    field(:first_name, :text).
    field(:last_name, :text).
    field(:phone, :text, required: false)

links \
  link(:self, invites_path)