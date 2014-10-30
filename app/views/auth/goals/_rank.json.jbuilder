ranks_json.item_init(local_assigns[:rel] || 'item')

ranks_json.properties(rank)

@qualifications = rank.qualifications
ranks_json.user_entities(rank)
