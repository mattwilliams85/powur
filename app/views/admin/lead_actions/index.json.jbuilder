siren json

klass :lead_actions, :list

json.entities @actions, partial: 'item', as: :lead_action

self_link lead_actions_path(format: :json)