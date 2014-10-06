siren json

klass :overrides, :list

json.entities @overrides, partial: 'item', as: :override

if @user
  actions action(:create, :post, admin_user_overrides_path(@user))
    .field(:kind, :select, options: UserOverride.enum_options(:kinds))
    .field(:start_date, :select,
           required:  false,
           reference: { url: pay_periods_path, id: :id, name: :title })
    .field(:end_date, :date, required: false)
end

links link(:self, @user ? admin_user_overrides_path(@user) : overrides_path)
