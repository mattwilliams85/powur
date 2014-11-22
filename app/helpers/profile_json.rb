class ProfileJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :users, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :profile

    entity_rel(rel) if rel
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :user
  end

  def detail_properties(user = @item)
    list_item_properties

    json.properties do
      json.call(user, :first_name, :last_name, :email, :phone,
                :bio, :avatar, :avatar_file_name, :address,
                :city, :state, :zip, :large_image_url,
                :medium_image_url, :thumb_image_url)

    end
  end

  # def user_entities(user)
  #   entities \
  #     entity(%w(list users), 'user-children', downline_user_path(user)),
  #     entity(%w(list users), 'user-ancestors', upline_user_path(user)),
  #     entity(%w(list orders), 'user-orders', user_orders_path(user)),
  #     entity(%w(list order_totals), 'user-order_totals',
  #            user_order_totals_path(user)),
  #    entity(%w(list rank_achievements), 'user-rank_achievements',
  #            user_rank_achievem ents_path(user))
  # end

  def update_action(profile_path, user)
    actions \
      action(:update, :patch, profile_path)
        .field(:first_name, :text, value: user.first_name)
        .field(:last_name, :text, value: user.last_name)
        .field(:email, :email, value: user.email)
        .field(:phone, :text, value: user.phone)
        .field(:address, :text, value: user.address)
        .field(:city, :text, value: user.city)
        .field(:state, :text, value: user.state)
        .field(:zip, :text, value: user.zip)
        .field(:provider, :text, value: user.provider)
        .field(:monthly_bill, :text, value: user.monthly_bill)
        .field(:bio, :text, value: user.bio)
        .field(:twitter_url, :text, value: user. twitter_url)
        .field(:linkedin_url, :text, value: user. linkedin_url)
        .field(:facebook_url, :text, value: user. facebook_url)
  end
end
