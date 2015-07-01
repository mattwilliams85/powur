users_json.item_init(local_assigns[:rel] || 'team_item')

users_json.list_item_properties(user)

json.properties do 
  json.downline_count User.with_ancestor(user.id).count
  json.proposal_count user.quotes.count
end

self_link user_path(user)

users_json.item_actions(user)