siren json

json.entities @stats_items do |i|
  json.properties do
    json.name i[:name]
    json.value i[:value]
  end
end
