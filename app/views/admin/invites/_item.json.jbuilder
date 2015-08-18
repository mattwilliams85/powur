klass :invite

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(invite,
            :id, :email, :first_name, :last_name, :user_id,
            :sponsor_id, :created_at, :updated_at, :expires, :status)
  json.sponsor_full_name invite.sponsor.full_name
end
