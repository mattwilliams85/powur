klass :resource_topic

json.properties do
  json.call(resource_topic, :id, :title, :position)
end

actions \
  action(:show, :get, admin_resource_topic_path(resource_topic)),
  action(:update, :put, admin_resource_topic_path(resource_topic)),
  action(:destroy, :delete, admin_resource_topic_path(resource_topic))

links \
  link(:self, admin_resource_topic_path(resource_topic))
