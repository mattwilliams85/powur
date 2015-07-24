json.properties do
  json.call(resource,
            :id, :title, :description, :tag_line, :file_original_path,
            :file_type, :youtube_id, :image_original_path, :position, :topic_id)
end

links link(:self, resource_path(resource))
