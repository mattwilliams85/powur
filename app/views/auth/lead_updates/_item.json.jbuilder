siren json

klass :lead_update

entity_rel(rel) if rel

json.properties do
  json.call(lead_update, :status, :updated_at, :lead_status, :opportunity_stage)
  json.data do
    lead_update.data.each do |key, value|
      json.set! key, value
    end
  end
end
