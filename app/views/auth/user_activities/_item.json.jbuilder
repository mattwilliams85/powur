klass :user_activity

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(user_activity, :id, :event, :event_time)
end
