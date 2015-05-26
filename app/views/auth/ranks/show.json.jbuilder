siren json

json.partial! 'item', rank: @rank

entities entity(%w(user_groups),
                'rank-user_groups',
                user_groups_path(rank: @rank.id))
