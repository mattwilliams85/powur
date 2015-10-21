klass :invite

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.code :id
  json.call(invite,
            :id, :first_name, :last_name, :email, :phone,
            :status, :created_at, :expires, :expiration_progress)
end

actions = []
actions << action(:resend, :post, resend_invite_path(invite)) if invite.expired?
if invite.redeemed?
  ations << action(:delete, :delete, delete_invite_path(invite))
end

actions(*actions)

links link :self, invite_path(invite)
