klass :notification

json.properties do
  json.call(notification,
            :id,
            :user_id,
            :content,
            :is_public,
            :recipient,
            :sent_at,
            :finished_at,
            :created_at,
            :updated_at)
  json.user do
    json.full_name notification.user.full_name
  end
  json.sender do
    json.full_name notification.sender.full_name
  end if notification.sender
end

actions \
  action(:update, :patch, admin_notification_path(notification))
  .field(:content, :text, value: notification.content),
  action(:delete, :delete, admin_notification_path(notification)),
  action(:send_out, :post, send_out_admin_notification_path(notification))

link_list = []
if notification.is_public && !notification.sent_at
  Notification::RECIPIENTS.each do |recipient|
    link_list << link("send to #{recipient}", recipient)
  end
end
links(*link_list)
