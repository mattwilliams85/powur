klass :user_group

entity_rel(local_assigns[:rel] || 'item')

json.properties do
  json.call(user_group, :id, :title, :description)
end

actions \
  action(:show, :get, user_group_path(user_group)),
  action(:update, :put, user_group_path(user_group)),
  action(:destroy, :delete, user_group_path(user_group))

self_link user_group_path(user_group)
