json.properties do
  json.id resource.id
  json.title resource.title
  json.description resource.description
  json.tag_line resource.tag_line
  json.file_original_path resource.file_original_path
  json.file_type resource.file_type
  json.youtube_id resource.youtube_id
  json.image_original_path resource.image_original_path
  json.position resource.position
  json.topic_id resource.topic_id
end

links link(:self, resource_path(resource))
