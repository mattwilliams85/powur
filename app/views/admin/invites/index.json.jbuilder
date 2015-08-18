siren json
klass :invites, :list
json.entities @invites, partial: 'item', as: :invite

self_link admin_invites_path(pending: params[:pending])
