siren json

users_json.item_init

users_json.detail_properties

users_json.admin_entities

actions users_json.update_action(admin_user_path(@user)),
  action(:move, :post, move_admin_user_path(@user))
    .field(:parent_id, :select,
           required: true,
           reference: { url:  eligible_parents_admin_user_path(@user),
                        id:   :id,
                        name: :full_name })

self_link admin_user_path(@user)
