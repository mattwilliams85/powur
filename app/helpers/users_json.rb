class UsersJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :users, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :user

    entity_rel(rel) if rel
  end

  LIST_PROPS = %w(downline_count personal personal_lifetime group 
                  group_lifetime)
  def list_item_properties(user = @item) # rubocop:disable Metrics/AbcSize
    json.properties do
      json.call(user, :id, :first_name, :last_name, :email, :phone, :level,
                :moved, :image_original_path)
      json.downline_count user.downline_users_count(user.id)
      LIST_PROPS.each do |field|
        json.set! field, user.attributes[field] if user.attributes[field]
      end
      json.avatar do
        [ :thumb, :medium, :large ].each do |key|
          json.set! key, user.avatar.url(key)
        end
      end if user.avatar?
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :user
  end

  def rank_title(rank_id)
    rank = all_ranks[rank_id || 0]
    rank ? rank.title : nil
  end

  def detail_properties(user = @item) # rubocop:disable Metrics/AbcSize
    list_item_properties
    json.properties do
      json.call(user, :address, :city, :state, :zip, :profile, :avatar, :avatar_file_name)
      json.organic_rank rank_title(user.organic_rank)
      json.lifetime_rank rank_title(user.lifetime_rank)
      json.downline_count user.downline_users_count(user.id)
      if user.rank_path_id
        json.rank_path all_paths.find { |p| p.id == user.rank_path_id }.name
      end
    end
  end

  def item_actions(user)
    if user.placeable?(current_user)
      json.actions do
        json.name "place"
        json.method "UPDATE"
        json.href "/u/users/"+user.id.to_s+"?sponsor_id="
        json.type "application/json"
      end
    end
  end

  def admin_entities(user = @item) # rubocop:disable Metrics/AbcSize
    entities \
      entity(%w(list users), 'user-children', downline_admin_user_path(user)),
      entity(%w(list users), 'user-ancestors', upline_admin_user_path(user)),
      entity(%w(list orders), 'user-orders', admin_user_orders_path(user)),
      entity(%w(list order_totals), 'user-order_totals',
             admin_user_order_totals_path(user)),
      entity(%w(list rank_achievements), 'user-rank_achievements',
             admin_user_rank_achievements_path(user)),
      entity(%w(list bonus_payments), 'user-bonus_payments',
             admin_user_bonus_payments_path(user)),
      entity(%w(list overrides), 'user-overrides',
             admin_user_overrides_path(user)),
      entity(%w(list pay_periods), 'user-pay_periods',
             admin_user_pay_periods_path(user))
  end

  def user_entities(user = @item)
    entities \
      entity(%w(list users), 'user-children', downline_user_path(user)),
      entity(%w(list users), 'user-ancestors', upline_user_path(user)),
      entity(%w(list orders), 'user-orders', user_orders_path(user)),
      entity(%w(list order_totals), 'user-order_totals',
             user_order_totals_path(user)),
      entity(%w(list rank_achievements), 'user-rank_achievements',
             user_rank_achievements_path(user))
  end

  def update_action(path, user = @item) # rubocop:disable Metrics/AbcSize
    action(:update, :patch, path)
      .field(:first_name, :text, value: user.first_name)
      .field(:last_name, :text, value: user.last_name)
      .field(:email, :email, value: user.email)
      .field(:phone, :text, value: user.phone)
      .field(:address, :text, value: user.address)
      .field(:city, :text, value: user.city)
      .field(:state, :text, value: user.state)
      .field(:zip, :text, value: user.zip)
  end
end
