siren json

klass :users, :list

json.entities @users, partial: 'auth/kpi_metrics/proposals/item', as: :user

json.max_page @max_page