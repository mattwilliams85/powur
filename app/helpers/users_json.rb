module UsersJson
  class UsersViewDecorator < JsonDecorator
    def list_init(partial_path = 'item')
      klass :users, :list

      list_entities(partial_path)
    end

    def item_init(rel = nil)
      klass :user

      entity_rel(rel) if rel
    end

    def list_item_properties(user = @item)
      json.properties do
        json.call(user, :id, :first_name, :last_name, :email, :phone, :level)
        %w(downline_count).each do |field|
          json.set! field, user.attributes[field] if user.attributes[field]
        end
      end
    end

    def list_entities(partial_path, list = @list)
      json.entities list, partial: partial_path, as: :user
    end

    def detail_properties(user = @item)
      list_item_properties

      json.properties do
        json.call(user, :address, :city, :state, :zip, :organic_rank,
                  :lifetime_rank)
      end
    end

    def admin_entities(user = @item)
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
               admin_user_overrides_path(user))
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

    def update_action(path, user = @item)
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

  def users_json
    @users_json ||= UsersViewDecorator.new(self, @users, @user)
  end
end
