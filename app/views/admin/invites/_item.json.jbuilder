klass :invite

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(invite, :id, :email, :first_name, :last_name, :sponsor_id, :created_at, :updated_at, :expires)
end

