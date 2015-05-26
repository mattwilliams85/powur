siren json

klass :user_groups, :list

json.entities @groups, partial: 'item', as: :user_group

if admin?
  actions action(:create, :post, user_groups_path)
    .field(:id, :text, required: true)
    .field(:title, :text, required: true)
    .field(:description, :text, required: false)
end

self_link user_groups_path
