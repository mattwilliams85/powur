module Auth
  class UsersController < AuthController
    before_action :fetch_user, only: [ :downline, :upline, :show, :update ]

    sort user: 'users.last_name asc, users.first_name asc'
    filter :performance,
           fields: { metric: { options: { personal: 'Personal Sales',
                                          group:    'Group Sales' } },
                     period: { options: { monthly:  'Monthly',
                                          lifetime: 'Lifetime' } } },
           scope_opts: { type: :hash, using: [ :metric, :period ] }

    def index(query = list_criteria)
      @users = apply_list_query_options(query)

      render 'index'
    end

    def downline
      @users = @user.downline_users

      render 'index'
    end

    def upline
      @users = @user.upline_users

      render 'index'
    end

    def search
      index(list_criteria.search(params[:search]))
    end

    def team
      query = User.where(sponsor_id: current_user.id)
      query = query.user_search(params[:search]) if params[:search]
      @users = apply_list_query_options(query)
    end

    def show
    end

    private

    def list_criteria
      User.with_parent(current_user.id)
    end

    def fetch_user
      @user = User.find_by(id: params[:id]) || not_found!(:user)
    end
  end
end
