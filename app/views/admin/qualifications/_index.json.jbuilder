
klass :qualifications, :list

json.entities qualifications, partial: 'admin/qualifications/item', as: :qualification

actions \
  action(:create, :post, rank_qualifications_path(rank))