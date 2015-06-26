klass :invite

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(invite, :id, :email, :first_name, :last_name, :sponsor_id, :created_at, :updated_at, :expires, :user_id)
end

actions \
  action(:resend, :post, resend_admin_user_invite_path(@user, invite)),
  action(:delete, :delete, admin_user_invite_path(@user, invite))