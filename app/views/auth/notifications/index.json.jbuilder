siren json

notifications_json.list_init

json.entities @notifications, partial: 'item', as: :notification

actions index_action(user_notifications_path, true)

self_link user_notifications_path