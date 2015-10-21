siren json

klass :invites, :list

json.properties do
  json.available_count current_user.available_invites
  json.accepted_count current_user.invites.redeemed.count
  json.expired_count current_user.invites.expired.count
  json.pending_count current_user.invites.pending.count
  json.limited_invites current_user.limited_invites?
end

json.entities @invites, partial: 'item', as: :invite

actions action(:create, :post, request.path)
  .field(:email, :email)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:phone, :text)

self_link request.path
