klass :lead_action

json.properties do
  json.call(lead_action,
            :id,
            :completion_chance,
            :action_copy)
  json.lead_stage lead_action.stage_name
end

actions \
  action(:update, :patch, lead_action_path(lead_action))
  .field(:completion_chance, :integer, value: lead_action.completion_chance)
  .field(:action_copy, :text, value: lead_action.action_copy)

links link(:self, lead_actions_path(lead_action))




