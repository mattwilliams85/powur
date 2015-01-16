siren json

users_json.item_init

users_json.detail_properties

users_json.user_entities

actions action(:move, :post, move_user_path(@user))
  .field(:parent_id, :select,
         required: true,
         reference: { url:  eligible_parents_user_path(@user),
                      id:   :id,
                      name: :full_name })

self_link user_path(@user)
