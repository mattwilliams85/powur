
klass :rank_achievement

json.rel [ :item ] unless local_assigns[:detail]

rank_achievements_json.item_init(local_assigns[:rel] || 'item')

rank_achievements_json.list_item_properties(rank_achievement)

self_link admin_user_rank_achievements_path(rank_achievement)
