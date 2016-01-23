json.properties do
  json.team @team_count || 0
  json.co2 @co2_count || 0
  json.earnings @earnings_total || 0
  json.partners @partners || 0
end
