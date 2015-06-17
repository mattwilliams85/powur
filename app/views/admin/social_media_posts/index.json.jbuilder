siren json

social_media_posts_json.list_init

json.entities @social_media_posts, partial: 'item', as: :social_media_post

actions \
  action(:create, :post, admin_social_media_posts_path)
  .field(:content, :text)
  .field(:publish, :boolean)

self_link admin_social_media_posts_path