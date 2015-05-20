siren json

klass :lead_update

entity_rel(rel) if rel

json.properties do
  json.call(lead_update, :status, :consultation, :contract, :installation, :updated_at)
  json.data do
    lead_update.data.each do |key, value|
      json.set! key, value
    end
  end
end