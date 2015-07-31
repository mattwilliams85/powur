module Auth
  class UsersController < AuthController
    before_action :fetch_users, only: [ :index ]
    before_action :fetch_user,
                  only: [ :show, :downline, :upline,
                          :full_downline, :move, :eligible_parents ]

    page
    sort newest:     { created_at: :desc },
         name:       'users.last_name asc, users.first_name asc',
         lead_count: 'lc.lead_count desc nulls last',
         team_count: 'tc.team_count desc nulls last'
    item_totals :lead_count, :team_count

    helper_method :user_totals

    def index
      @users = @users.search(params[:search]) if params[:search].present?
      @users = apply_list_query_options(@users)

      render 'index'
    end

    def downline
      @users = User.with_parent(@user.id)
      @users = apply_list_query_options(@users)

      index
    end

    def full_downline
      scope = User.with_ancestor(params['id'])
      apply_list_query_options(scope)
      query_users(scope) if params[:search]

      render 'index'
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
        not_found!(:user, parent.id)
      end

      User.move_user(@user, parent)

      show
    end

    def query_users(scope)
      if params[:search].to_i > 0
        @users = scope.where(id: params[:search].to_i)
      else
        @users = scope
          .search(params[:search])
          .limit(7)
          .order(:first_name)
      end
    end

    private

    def fetch_users
      @users = admin? ? User.all : User.with_ancestor(current_user.id)
    end

    def fetch_user
      params[:user_id] = params[:id]
      super
    end

    def user_team_counts
      { all:       User.with_ancestor(@user.id).count,
        certified: User.with_ancestor(@user.id).with_purchases.count }
    end

    def user_lifetime_lead_counts
      { submitted: @user.leads.submitted.count,
        installed: @user.leads.installed.count }
    end

    def user_month_lead_counts
      month_start = Date.today.beginning_of_month
      submitted_month = @user.leads
        .submitted.where('submitted_at >= ?', month_start).count
      installed_month = @user.leads
        .installed.where('submitted_at >= ?', month_start).count

      { submitted: submitted_month,
        installed: installed_month }
    end

    def user_lead_counts
      { lifetime: user_lifetime_lead_counts,
        month:    user_month_lead_counts }
    end

    def user_totals
      @user_totals ||= begin
        { team_counts: user_team_counts, lead_counts: user_lead_counts }
      end
    end
  end
end
