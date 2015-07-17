siren json

klass :news_posts, :list

json.entities @news_posts, partial: 'item', as: :news_post

actions index_action(user_news_posts_path, true)

self_link user_news_posts_path
