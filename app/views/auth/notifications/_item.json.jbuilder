klass :news_post

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(news_post, :id, :content, :created_at, :updated_at)
end

links link(:self, user_news_post_path(news_post))
