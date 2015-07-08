siren json

klass :invites, :list

json.properties do
  json.available current_user.available_invites
  json.redeemed current_user.redeemed_invites
end

json.entities @invites, partial: 'item', as: :invite

actions action(:create, :post, request.path)
  .field(:email, :email)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:phone, :text, required: false)

self_link request.path
