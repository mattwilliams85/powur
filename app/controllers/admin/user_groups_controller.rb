module Admin
  class UserGroupsController < AdminController
    before_action :fetch_group, only: [ :show, :update, :destroy ]

    def index
      @groups = UserGroup.order(:id)

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      @user_group = UserGroup.create(input.merge(id: params[:id]))
      if @user_group.valid?
        show
      else
        render json: { errors: @user_group.errors.messages }, status: :unprocessable_entity
      end
    end

    def update
      @user_group.update_attributes!(input)
      show
    end

    def destroy
      @user_group.destroy
      head 200
    end

    private

    def fetch_group
      @user_group = UserGroup.find(params[:id])
    end

    def input
      allow_input(:title, :description)
    end
  end
end
