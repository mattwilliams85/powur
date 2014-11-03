module Auth
  class UsersController < AuthController
    before_action :fetch_user, only: [ :downline, :upline, :show, :update ]

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

    def index(query = list_criteria)
      @users = apply_list_query_options(query)

      render 'index'
    end

    def downline
      index(User.with_parent(@user.id))
    end

    def upline
      @users = @user.upline_users

      render 'index'
    end

    def search
      index(list_criteria.search(params[:search]))
    end

    def show
    end

    private

    def list_criteria
      User.with_parent(current_user.id)
    end

    def fetch_user
      @user = User.find_by(id: params[:id].to_i) || not_found!(:user)
    end
  end
end
