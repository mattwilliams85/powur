klass :user

entity_rel(local_assigns[:rel] || 'item')

item_props(user) do
  json.call(user, :id, :first_name, :last_name, :full_name, :email,
            :phone, :level, :moved, :profile, :lifetime_rank, :level,
            :upline, :created_at, :sponsor_id)
  json.certified user.partner?
  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, asset_path(user.avatar.url(key))
    end
  end if user.avatar?
end

self_link user_path(user)
