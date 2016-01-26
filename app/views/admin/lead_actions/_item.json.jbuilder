def stage_value(action)
  return 'post' if action.sales_status || 
                   action.opportunity_stage || 
                   action.lead_status
  return 'pre'
end


klass :lead_action

json.properties do
  json.call(lead_action,
            :id,
            :completion_chance,
            :action_copy,
            :sales_status,
            :data_status,
            :lead_status,
            :opportunity_stage)
  json.stage_names lead_action.stage_name
  json.stage stage_value(lead_action)
end

actions \
  action(:update, :patch, lead_action_path(lead_action))
  .field(:stage, :radio, options: ['pre', 'post'], value: stage_value(lead_action))
  .field(:data_status, :select, options: Lead.data_statuses.keys, value: lead_action.data_status)
  .field(:sales_status, :select, options: Lead.sales_statuses.keys, value: lead_action.sales_status)
  .field(:opportunity_stage, :select, 
         options: LeadUpdate.select(:opportunity_stage).distinct.map(&:opportunity_stage), 
         value: lead_action.opportunity_stage)
  .field(:lead_status, :select, 
         options: LeadUpdate.select(:lead_status).distinct.map(&:lead_status), 
         value: lead_action.lead_status)
  .field(:completion_chance, :number, value: lead_action.completion_chance)
  .field(:action_copy, :text, value: lead_action.action_copy),
  action(:delete, :delete, lead_action_path(lead_action))

links link(:self, lead_actions_path(lead_action))




