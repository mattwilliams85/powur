klass :invite

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.code :id
  json.call(invite,
            :id, :first_name, :last_name, :email, :phone,
            :status, :created_at, :expires, :expiration_progress)
end

actions \
  action(:resend, :post, resend_invite_path(invite)),
  action(:delete, :delete, delete_invite_path(invite))

links link :self, invite_path(invite)
