users_json.item_init(local_assigns[:rel] || 'item')

users_json.list_item_properties(user)

json.properties do
  json.call(user,
            :available_invites,
            :lifetime_invites_count,
            :open_invites_count,
            :redeemed_invites_count)
  json.submitted_proposals_count @user.team_lead_count
end

actions \
  action(:award, :patch, admin_user_invites_path(user))
  .field(:invites, :number, required: true)

self_link admin_user_path(user)
