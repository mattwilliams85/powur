siren json

json.partial! 'item', user_group: @user_group

entities \
  entity(%w(requirements list),
        'user_group-requirements',
         user_group_requirements_path(user_group_id: @user_group))

if admin?
  actions action(:delete, :delete, user_group_path(@user_group)),
          action(:update, :patch, user_group_path(@user_group))
            .field(:title, :text, required: true)
            .field(:description, :text, required: false)
end
