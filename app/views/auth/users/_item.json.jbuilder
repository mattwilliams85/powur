klass :user

entity_rel(local_assigns[:rel] || 'item')

item_props(user) do
  json.call(user, :id, :first_name, :last_name, :full_name, :email,
            :phone, :level, :moved, :profile, :lifetime_rank, :level,
            :upline, :created_at, :sponsor_id)
  json.certified user.partner?
  lifetime_rank = all_ranks[user.lifetime_rank || 0]
  json.lifetime_rank_title lifetime_rank && lifetime_rank.title
  json.team_lead_count user.team_lead_count
  json.lead_count user.leads.submitted.count
  json.totals user_totals(user) if params[:user_totals]
  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, asset_path(user.avatar.url(key))
    end
  end if user.avatar?
end

self_link user_path(user)
