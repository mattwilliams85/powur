klass :notification

json.properties do
  json.call(notification, :id, :user_id, :content, :created_at, :updated_at)
end

actions \
  action(:update, :patch, admin_notification_path(notification))
  .field(:content, :text, value: notification.content),
  action(:delete, :delete, admin_notification_path(notification))

links link(:self, admin_notification_path(notification))
