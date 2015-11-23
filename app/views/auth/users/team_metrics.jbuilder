siren json

klass :user, :team_metrics

json.properties do
  json.grid_count User.with_ancestor(@user.id).count
  json.grid_partners_count User.with_ancestor(@user.id).with_purchases.count
end

self_link request.path
