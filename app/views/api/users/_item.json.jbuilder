users_json.item_init(local_assigns[:rel] || 'item')

users_json.list_item_properties(user)

self_link api_user_path(v: params[:v], id: user)
