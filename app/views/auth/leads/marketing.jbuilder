siren json

klass :leads, :marketing

json.properties do
  json.call(current_user,
            :solar_landing_leads_count,
            :solar_landing_views_count,
            :solar_landing_team_leads_count,
            :solar_landing_team_views_count)
end

self_link request.path
