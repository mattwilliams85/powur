klass :user_group

entity_rel(local_assigns[:rel] || 'item')

json.properties do
  json.call(user_group, :id, :title, :description)
end

self_link user_group_path(user_group)
