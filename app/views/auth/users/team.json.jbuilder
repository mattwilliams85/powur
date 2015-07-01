siren json

klass :users, :list

json.entities @users, partial: 'team_item', as: :user

# actions \
#   index_action(users_path, true)
#   .field(:sort_by, :select, options: { rank: 'ranks', quotes: 'quotes',
#                           recruits: 'new recruits' })
#   .field(:pay_period, :select,
#          options:   { lifetime: 'lifetime', monthly: 'current month', weekly: 'current week' },
#          required:  false,
#          reference: { url: team_user_path, id: :id, name: :title })

# links \
#   link(:self, users_path)
# link(:self, profile_path)
