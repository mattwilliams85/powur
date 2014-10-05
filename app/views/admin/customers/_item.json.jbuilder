klass :customer

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(customer, :id, :first_name, :last_name, :email, :phone)
end
