siren json

klass :notifications, :list

json.entities @notifications, partial: 'item', as: :notification

json.properties do
  json.sms_advocates_count User.advocates.can_sms.count
  json.sms_partners_count User.partners.can_sms.count
end

actions \
  action(:create, :post, admin_notifications_path).field(:content, :text)

self_link admin_notifications_path
