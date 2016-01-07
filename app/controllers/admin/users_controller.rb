module Admin
  class UsersController < AdminController
    before_action :fetch_user,
                  only: [ :downline, :upline, :show, :update,
                          :sponsors, :eligible_parents, :move, :update_sponsor,
                          :terminate ]

    page max_limit: 25
    sort id_desc:         { id: :desc },
         id_asc:          { id: :asc },
         first_name_asc:  { first_name: :asc },
         first_name_desc: { first_name: :desc }
    filter :with_purchases,
           url:        -> { admin_users_path },
           scope_opts: { type: :boolean },
           required:   false
    filter :advocates,
           url:        -> { admin_users_path },
           scope_opts: { type: :boolean },
           required:   false
    filter :partners,
           url:        -> { admin_users_path },
           scope_opts: { type: :boolean },
           required:   false

    def index
      @users = apply_list_query_options(User)
      return unless params[:group]
      group_ids = params[:group].split(',')
      @users = @users.in_groups(*group_ids)
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
      render 'show'
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

      show
    end

    def eligible_parents
      require_input :search
      @users = apply_list_query_options(
        @user.eligible_parents.search(params[:search]))

      render :index
    end

    def sponsors
      @users = [ @user.sponsor, @user.sponsor.try(:sponsor) ].compact

      render 'sponsors'
    end

    def update_sponsor
      sponsor_id = params[:sponsor_id]
      error!(:update_sponsor_self) if @user.id == sponsor_id
      error!(:update_sponsor_no_sponsor) if @user.sponsor_id.nil?
      if User.all_team(@user.id).find_by(id: sponsor_id)
        error!(:update_sponsor_in_downline)
      end

      @user.update_attribute(:sponsor_id, sponsor_id)
      head :ok
    end

    def move
      require_input :parent_id
      parent = User.find(params[:parent_id].to_i)
      User.move_user(@user, parent)

      show
    end

    def terminate
      @user.update_attribute(:terminated, 'true')
      head :ok
    end

    protected

    def fetch_user
      params[:user_id] = params[:id]
      super
    end
  end
end
