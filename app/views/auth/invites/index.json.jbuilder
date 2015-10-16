siren json

klass :invites, :list

json.properties do
  json.available_count current_user.available_invites
  json.accepted_count current_user.invites.redeemed.count
  json.expired_count current_user.invites.expired.count
  json.pending_count current_user.invites.pending.count
end

json.entities @invites, partial: 'item', as: :invite

actions action(:create, :post, request.path)
  .field(:email, :email)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:phone, :text, required: false) # should we require this?

self_link request.path
