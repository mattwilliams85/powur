module Auth
  class UsersController < AuthController
    before_action :verify_rank, except: [ :index, :show ]

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
