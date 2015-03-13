siren json

json.partial! 'admin/user_groups/item', user_group: @user_group

entities \
  entity(%w(list users),
         'user_group-users',
         admin_users_path(group: @user_group.id)),
  entity('requirements', 'user_group-requirements', user_group: @user_group)

actions action(:delete, :delete, user_group_path(@user_group)),
        action(:update, :patch, user_group_path(@user_group))
          .field(:title, :text, required: true)
          .field(:description, :text, required: false)
