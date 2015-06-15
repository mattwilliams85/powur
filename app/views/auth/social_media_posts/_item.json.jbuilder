klass :social_media_post

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(social_media_post, :id, :content, :publish, :created_at, :updated_at)
end

links link(:self, user_social_media_post_path(social_media_post))