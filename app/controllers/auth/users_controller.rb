module Auth
  class UsersController < AuthController
    before_action :fetch_users, only: [ :index ]
    before_action :fetch_user,
                  only: [ :show, :downline, :upline, :move, :eligible_parents ]

    page
    sort newest: { created_at: :desc },
         name:   'users.last_name asc, users.first_name asc'
    item_totals :leads_count, :team_count

    def index
      @users = @users.search(params[:search]) if params[:search].present?
      @users = apply_list_query_options(@users)

      render 'index'
    end

    def downline
      @users = User.with_parent(@user.id)

      index
    end

    def upline
      @users = @user.upline_users

      index
    end

    def eligible_parents
      @users = @user.eligible_parents(current_user)

      index
    end

    def show
      render 'show'
    end

    def move
      require_input :parent_id

      parent = User.find(params[:parent_id].to_i)
      unless @user.eligible_parent?(parent.id, current_user)
        not_found!(:user, current_user.id)
      end

      User.move_user(@user, parent)

      show
    end

    private

    def fetch_users
      @users = admin? ? User.all : User.with_ancestor(current_user.id)
    end

    def fetch_user
      params[:user_id] = params[:id]
      super
    end

    def leads_count(query)
      ids = query.entries.map(&:id)
      totals = User.quote_count(ids: ids)

      Hash[ totals.map { |t| [ t.id, t.attributes['quote_count'] ] } ]
    end

    def team_count(query)
      ids = query.entries.map(&:id)
      totals = User.team_count(ids: ids)

      Hash[ totals.map { |t| [ t.id, t.attributes['team_count'] ] } ]
    end
  end
end
