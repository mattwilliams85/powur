klass :social_media_post

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(social_media_post,
            :id, :content, :publish, :created_at, :updated_at)
end

actions \
  action(:update, :patch, admin_social_media_post_path(social_media_post))
  .field(:content, :text, value: social_media_post.content)
  .field(:publish, :boolean, value: social_media_post.publish),
  action(:delete, :delete, admin_social_media_post_path(social_media_post))

links link(:self, admin_social_media_post_path(social_media_post))
