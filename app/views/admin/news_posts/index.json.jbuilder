siren json

klass :news_posts, :list

json.entities @posts, partial: 'item', as: :news_post

actions \
  action(:create, :post, admin_news_posts_path)
  .field(:content, :text)

self_link admin_news_posts_path
