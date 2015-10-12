klass :customer

json.properties do
  json.call(invite, :id, :status, :full_name, :email)
end

self_link product_invite_path(invite)
