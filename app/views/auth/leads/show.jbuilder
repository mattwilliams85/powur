siren json

json.partial! 'auth/leads/item', lead: @lead

json.properties do
  json.product_fields @lead.data.each { |key, value| json.set! key, value }
end

if @lead.last_update
  entities entity('auth/lead_updates/item', 'lead-update',
                  lead_update: @lead.last_update)
end

if current_user.role?(:admin)
  actions << action(:switch_owner, :patch, switch_owner_lead_path(@lead))
    .field(:user_id, :number, value: @lead.user_id)
end
