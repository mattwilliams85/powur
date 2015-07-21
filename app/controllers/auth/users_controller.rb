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
      scope = User.with_parent(@user.id)

      if params[:search]
        @users = User.search(params[:search]) 
      elsif params[:sort] == 'proposals'
        @users = scope.quote_performance(@user.id)
      elsif params[:sort] == 'team'
        @users = User.team_size(@user.id)
      else
        @users = apply_list_query_options(scope)
      end

      render 'team'
    end

    def full_downline
      scope = User.with_ancestor(params['id'])

      query_users(scope) if params[:search]

      render 'team'
    end

    def query_users(scope)
      if params[:search].to_i > 0
        @users = scope.where(id: params[:search].to_i)
      else 
        @users = scope
        .where("lower(first_name || ' ' || last_name) LIKE ?", "%#{params[:search].downcase}%")
        .limit(7)
        .order(:first_name)
      end
    end

    def move
      # require_input :parent_id

      # child = User.find(params[:child_id])
      # parent = User.find(params[:parent_id])
      # child.assign_parent(parent)

      index
    end

    def show
      render 'show'
    end

    def move
      require_input :parent_id

      parent = User.find(params[:parent_id].to_i)
      unless @user.eligible_parent?(parent.id, current_user)
        not_found!(:user, parent.id)
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
