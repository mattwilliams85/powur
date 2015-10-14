klass :customer

json.properties do
  json.call(invite,
            :id, :status, :first_name, :last_name, :email, :phone,
            :full_address, :notes)
  json.updated_at invite.updated_at.to_f * 1000
end

self_link product_invite_path(invite)
