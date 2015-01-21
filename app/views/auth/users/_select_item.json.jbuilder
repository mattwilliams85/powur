
users_json.item_init(local_assigns[:rel] || 'item')

json.properties do
  json.call(user, :id, :full_name)
  json.depth user.level - current_user.level
end
