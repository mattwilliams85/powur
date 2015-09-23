klass :product_invite

json.properties do
  json.call(invite, :id, :product_id, :status)
  json.customer do
    json.full_name invite.customer.full_name
    json.email invite.customer.email
  end if invite.customer
end

self_link product_invite_path(invite)
