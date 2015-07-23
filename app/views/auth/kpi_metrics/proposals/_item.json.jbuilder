users_json.item_init(local_assigns[:rel] || 'item')

json.properties do
  json.call(user, :id, :first_name, :last_name, :proposal_count)

  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, asset_path(user.avatar.url(key))
    end
  end if user.avatar?
end
