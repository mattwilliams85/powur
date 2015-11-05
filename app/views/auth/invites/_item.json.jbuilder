klass :invite

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.code :id
  json.call(invite,
            :id, :first_name, :last_name, :email, :phone,
            :status, :created_at, :expires, :time_left)
end

actions = []
actions << action(:update, :patch, invite_path(invite))
  .field(:email, :email, value: invite.email)
  .field(:first_name, :text, value: invite.first_name)
  .field(:last_name, :text, value: invite.last_name)
  .field(:phone, :text, value: invite.phone)
actions << action(:resend, :post, resend_invite_path(invite)) if invite.expired?
actions << action(:delete, :delete, delete_invite_path(invite))
actions(*actions)

entity_list = [ entity(%w(email),
                       'invite-email',
                       email_invite_path(invite.id)) ]

entities(*entity_list)

links link :self, invite_path(invite)
