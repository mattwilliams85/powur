module Auth
  class UsersController < AuthController
    before_action :fetch_user, only: [ :show, :downline, :upline, :update ]

    sort user: 'users.last_name asc, users.first_name asc'
    filter :performance,
           fields:     { metric: { options: { quotes:   'Quote Count',
                                              personal: 'Personal Sales',
                                              group:    'Group Sales' },
                                   heading: :order_by },
                         period: { options: { lifetime: 'Lifetime',
                                              monthly:  'Monthly',
                                              weekly:   'Weekly' },
                                   heading: :for_period } },
           scope_opts: { type: :hash, using: [ :metric, :period ] }

    def index
      @users = apply_list_query_options(list_query)

      render 'index'
    end

    def downline
      @list_query = User.with_parent(@user.id)

      index
    end

    def upline
      @list_query = @user.upline_users

      index
    end

    def search
      @list_query = list_query.search(params[:search])

      index
    end

    def show
    end

    private

    def list_query
      @list_query ||= User.with_parent(current_user.id)
    end

    def fetch_user
      @user = fetch_downline_user(params[:id].to_i)
    end
  end
end
