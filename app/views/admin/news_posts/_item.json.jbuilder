klass :news_post

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(news_post, :id, :content, :created_at, :updated_at)
end

actions \
  action(:update, :patch, admin_news_post_path(news_post))
  .field(:content, :text, value: news_post.content),
  action(:delete, :delete, admin_news_post_path(news_post))

links link(:self, admin_news_post_path(news_post))
