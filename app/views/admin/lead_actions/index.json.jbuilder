siren json

klass :lead_actions, :list

json.entities @actions, partial: 'item', as: :lead_action

actions \
  action(:create, :post, lead_actions_path)
  .field(:stage, :radio, options: ['pre', 'post'])
  .field(:data_status, :select, options: Lead.data_statuses.keys)
  .field(:sales_status, :select, options: Lead.sales_statuses.keys)
  .field(:opportunity_stage, :select, 
         options: LeadUpdate.select(:opportunity_stage).distinct.map(&:opportunity_stage))
  .field(:lead_status, :select, 
         options: LeadUpdate.select(:lead_status).distinct.map(&:lead_status))
  .field(:completion_chance, :number)
  .field(:action_copy, :text)

self_link lead_actions_path(format: :json)