klass :invite

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.code :id
  json.call(invite,
            :id, :first_name, :last_name, :email, :phone, :status)
  json.expires invite.expires.to_f * 1000
end

actions \
  action(:resend, :post, resend_invite_path(invite)),
  action(:delete, :delete, delete_invite_path(invite))

links link :self, invite_path(invite)
