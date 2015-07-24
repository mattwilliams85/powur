json.properties do
  json.call(resource,
            :id, :user_id, :title, :description, :tag_line,
            :file_original_path, :file_type, :youtube_id, :image_original_path,
            :is_public, :position, :topic_id, :topic)

  json.user_name resource.user.full_name
  json.created_at resource.created_at.to_f * 1000
end

actions \
  action(:show, :get, admin_resource_path(resource)),
  action(:update, :put, admin_resource_path(resource)),
  action(:destroy, :delete, admin_resource_path(resource))

links \
  link(:self, admin_resource_path(resource))
