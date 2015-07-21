module Admin
  class UsersController < AdminController
    
    before_action :fetch_user, only: [ :downline, :upline, :show, :update, :sponsors, :eligible_parents, :move ]

    page max_limit: 25
    sort id_desc:         { id: :desc },
         id_asc:          { id: :asc },
         first_name_asc:  { first_name: :asc },
         first_name_desc: { first_name: :desc }
    filter :with_purchases,
           url:        -> { admin_users_path },
           scope_opts: { type: :boolean },
           required:   false

    def index
      @users = apply_list_query_options(User)
      if params[:group]
        group_ids = params[:group].split(',')
        @users = @users.in_groups(*group_ids)
      end
    end

    def invites
      scope = User
      scope = scope.search(params[:search]) if params[:search]
      @users = apply_list_query_options(scope)
    end

    def downline
      @users = apply_list_query_options(@user.downline_users)

      render 'index'
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
      input = params.permit(:first_name, :last_name, :email, :phone,
                            :address, :city, :state, :zip,
                            :allow_sms, :allow_system_emails,
                            :allow_corp_emails,
                            :password, :password_confirm)

      if input[:password] && input[:password] != input[:password_confirm]
        error!(:password_confirm, :password_confirm)
      end
      input.delete(:password_confirm)

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

    def sponsors
      @users = [ @user.sponsor, @user.sponsor.try(:sponsor) ].compact

      render 'sponsors'
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
