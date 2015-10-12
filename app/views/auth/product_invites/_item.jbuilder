klass :customer

json.properties do
  json.call(customer, :id, :status, :full_name, :email)
end

self_link product_invite_path(customer)
