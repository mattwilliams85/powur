json.properties do
  json.id resource.id
  json.user_id resource.user_id
  json.title resource.title
  json.description resource.description
  json.tag_line resource.tag_line
  json.file_original_path resource.file_original_path
  json.file_type resource.file_type
  json.youtube_id resource.youtube_id
  json.image_original_path resource.image_original_path
  json.is_public !!resource.is_public
  json.user_name resource.user.full_name
  json.created_at resource.created_at.to_f * 1000
  json.position resource.position
  json.topic_id resource.topic_id
  json.topic resource.topic
end

actions \
  action(:show, :get, admin_resource_path(resource)),
  action(:update, :put, admin_resource_path(resource)),
  action(:destroy, :delete, admin_resource_path(resource))

links \
  link(:self, admin_resource_path(resource))
