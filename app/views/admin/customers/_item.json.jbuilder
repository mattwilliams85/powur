klass :customer

entity_rel(local_assigns[:rel] || :item) unless local_assigns[:detail]

json.properties do
  json.(customer, :id, :first_name, :last_name, :email, :phone)
end

