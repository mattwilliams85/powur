klass :notification

json.properties do
  json.call(notification,
            :id,
            :user_id,
            :content,
            :created_at,
            :updated_at)
  json.user do
    json.full_name notification.user.full_name
  end
end

json.entities notification.releases do |release|
  json.properties do
    json.user_full_name release.user.full_name
    json.recipient release.recipient
    json.sent_at release.sent_at ? release.sent_at.to_f * 1000 : nil
    json.finished_at release.finished_at ? release.finished_at.to_f * 1000 : nil
  end
end

actions \
  action(:update, :patch, admin_notification_path(notification))
  .field(:content, :text, value: notification.content),
  action(:delete, :delete, admin_notification_path(notification)),
  action(:send_out, :post, send_out_admin_notification_path(notification))

# link_list = []
# if notification.is_public && !notification.sent_at
#   Notification::RECIPIENTS.each do |recipient|
#     link_list << link("send to #{recipient}", recipient)
#   end
# end
# links(*link_list)
