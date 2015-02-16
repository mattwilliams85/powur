siren json

notifications_json.list_init

json.entities @notifications, partial: 'item', as: :notification

actions \
  action(:create, :post, admin_notifications_path)
  .field(:content, :text),
  index_action(admin_notifications_path, true)

self_link admin_notifications_path
