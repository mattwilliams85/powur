siren json

klass :notifications, :list

json.entities @notifications, partial: 'item', as: :notification

actions \
  action(:create, :post, admin_notifications_path).field(:content, :text)

self_link admin_notifications_path
