module Admin
  class UsersController < AdminController
    before_action :fetch_user, only: [ :downline, :upline, :show, :update, :eligible_parents, :move ]
    page max_limit: 25
    sort id_asc:        { id: :asc },
         id_desc:       { id: :desc }
    filter :has_rank, scope_opts: { type: :boolean }, required: false

    def index
      respond_to do |format|
        format.html
        format.json do
          @users = apply_list_query_options(User)
          if params[:group]
            group_ids = params[:group].split(',')
            @users = @users.in_groups(*group_ids)
          end
        end
      end
    end

    def downline
      @users = apply_list_query_options(@user.downline_users)

      render 'team'
    end

    def upline
      @users = apply_list_query_options(@user.upline_users)

      render 'index'
    end

    def search
      @users = apply_list_query_options(User.search(params[:search]))

      render 'index'
    end

    def show
    end

    def update
      input = allow_input(:first_name, :last_name, :email, :phone,
                          :address, :city, :state, :zip)

      @user.update_attributes!(input)

      render 'show'
    end

    def eligible_parents
      @users = User
        .where('NOT (? = ANY (upline))', @user.id)
        .where('id <> ?', @user.parent_id)
        .order(:upline)

      render 'auth/users/select_index'
    end

    def move
      require_input :parent_id

      parent = User.find(params[:parent_id].to_i)

      @user.assign_parent(parent, 'admin')

      render 'show'
    end

    protected

    def fetch_user
      params[:user_id] = params[:id]
      super
    end
  end
end
