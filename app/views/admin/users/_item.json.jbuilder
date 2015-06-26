users_json.item_init(local_assigns[:rel] || 'item')

users_json.list_item_properties(user)

json.properties do
  json.call(user, :awarded_invites, :submitted_proposals_count)
end

actions \
  action(:award, :patch, admin_user_invites_path(user))
  .field(:invites, :number, required: true)

self_link admin_user_path(user)
