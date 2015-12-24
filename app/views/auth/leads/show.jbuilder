siren json

json.partial! 'auth/leads/item', lead: @lead

json.properties do
  json.product_fields @lead.data.each { |key, value| json.set! key, value }
  json.call(@lead, :action_copy, :completion_chance) if @lead.lead_action?
end

if @lead.last_update
  entities entity('auth/lead_updates/item', 'lead-update',
                  lead_update: @lead.last_update)
end
