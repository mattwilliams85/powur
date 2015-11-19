siren json

klass :invites, :list

json.properties do
  # json.available_count current_user.available_invites
  json.accepted_count current_user.invites.redeemed.count
  json.expired_count current_user.invites.expired.count
  json.pending_count current_user.invites.pending.count
end

json.entities @invites, partial: 'item', as: :invite

actions = []
actions << action(:create, :post, request.path)
  .field(:email, :email)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:phone, :text)
  .field(:confirm_existing_email, :boolean) if current_user.partner?

actions(*actions)

self_link request.path
