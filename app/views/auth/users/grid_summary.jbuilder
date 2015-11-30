siren json

klass :user, :grid_summary

json.properties do
  json.team_count @user.metrics.team_count(days: params[:days])
  json.team_partners_count @user.metrics.team_count(days: params[:days], partners: true)
end

self_link request.path
