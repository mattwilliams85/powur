module Admin
  class UsersController < AdminController
    before_action :fetch_user, only: [ :downline, :upline, :show, :update, :eligible_parents, :move ]

    def index
      respond_to do |format|
        format.html
        format.json do
          @users = User.at_level(1).order(last_name: :desc, first_name: :desc)
          if params[:group]
            group_ids = params[:group].split(',')
            @users = @users.in_groups(*group_ids)
          end
        end
      end
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
      @users = User.search(params[:search])

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
