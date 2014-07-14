
item_list_name = entity[:data].model.name.downcase.pluralize
json.partial! "admin/#{item_list_name}/rank_index", 
  rank: entity[:rank], item_list_name.to_sym => entity[:data]

