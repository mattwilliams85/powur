klass :notification

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(notification, :id, :content, :created_at, :updated_at)
end

links link(:self, user_notification_path(notification))