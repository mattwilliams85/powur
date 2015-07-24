module Auth
  class UsersController < AuthController
    include UsersActions

    sort newest: { created_at: :desc },
         name: 'users.last_name asc, users.first_name asc'
          # quotes: 'users.quote_count asc'
          # # .with_quote_counts

    filter :performance,
           fields:     { metric: { options: [ :quote_count, :personal_sales, :group_sales ],
                                   heading: :order_by },
                         period: { options: [ :lifetime, :monthly, :weekly ],
                                   heading: :for_period } },
           scope_opts: { type: :hash, using: [ :metric, :period ] }

    def eligible_parents
      @users = User
        .with_ancestor(current_user.id)
        .where('NOT (? = ANY (upline))', @user.id)
        .where('id <> ?', @user.parent_id)
        .order(:upline)

      render 'select_index'
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
          .search(params[:search])
          .limit(7)
          .order(:first_name)
      end
    end

    def move
      # require_input :parent_id

      # child = User.find(params[:child_id])
      # parent = User.find(params[:parent_id])
      # child.assign_parent(parent)

      # @user = User.find(current_user.id)

      # render 'show'

      require_input :parent_id

      parent = User.find(params[:parent_id])
      if parent.ancestor?(current_user.id) && @user.ancestor?(current_user.id)
        @user.assign_parent(parent, 'user')
      else
        not_found!(:user, current_user.id)
      end

      # parent = User.with_parent(parent.id)
      #   .where(id: current_user.id).first
      # not_found!(:user, current_user.id) if parent.nil?

      render 'show'
    end

    def fetch_user
      params[:user_id] = params[:id]
      super
    end
  end
end
